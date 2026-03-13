#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

use core::{arch::asm, fmt::Write, panic::PanicInfo};
use x86_64::instructions::port::Port;
use x86_64::structures::idt::{InterruptDescriptorTable, InterruptStackFrame, PageFaultErrorCode};

const SERIAL_COM1: u16 = 0x3F8;
const IMPULSE_BASE: u64 = 0x00;
const LUX_SERIAL_STATUS: u8 = 0x40;
const BIT_BUSY: u8 = 0b000000000;

struct SerialWriter;

fn serial_write_byte(byte: u8) {
    unsafe {
        let mut status = Port::<u8>::new(SERIAL_COM1 + 5);
        while status.read() & 0x20 == 0 {}
        Port::<u8>::new(SERIAL_COM1).write(byte);
    }
}

// Twoja "Siódemka" dla COM1 (512B bufora)
// Umieszczamy to pod konkretnym Symbolem, np. 0x40 (SERIAL_STACK)
static mut SERIAL_BUFFER: [u8; 512] = [0; 512];
static mut SERIAL_HEAD: usize = 0; // Gdzie dopisujemy
static mut SERIAL_TAIL: usize = 0; // Gdzie UART odczytuje

impl Write for SerialWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for byte in s.bytes() {
            // serial_write_byte(byte);
            unsafe {
                // 1. Wrzucasz bajt na "Własny Stos" (Bufor kołowy)
                // SERIAL_BUFFER[SERIAL_HEAD % 512] = byte;
                SERIAL_BUFFER[SERIAL_HEAD % 512] = byte;
                SERIAL_HEAD += 1;
                
                // Tu możesz sprawdzić zajętość: 
                // let occupancy = SERIAL_HEAD - SERIAL_TAIL;
                // Jeśli occupancy > 400 -> Zmień kolor Glifa na czerwony!
            }
            trigger_serial_flush(byte); 
        }
        // 2. Wyzwalasz "Impuls Wykonawczy" (nie czekasz na koniec!)
        // trigger_serial_flush(); 
        Ok(())
    }
}

fn trigger_serial_flush(byte: u8) {
    // serial_write_byte(0x21);
    unsafe {
        // Czy UART już pracuje? (Sprawdzamy nasz Symbol 0x40 w RAM)
        if !is_bit_set(LUX_SERIAL_STATUS, BIT_BUSY) {
            // Jeśli śpi, to go budzimy pierwszym kęsem danych
            pull_from_serial_stack();
            let status_ptr = LUX_SERIAL_STATUS as *mut u8;
                set_bit(&mut *status_ptr, BIT_BUSY); // Symbol: "Pracuję!"
            outb(SERIAL_COM1, byte); // Pierwszy impuls w krzem
            }
        
        
        // serial_write_byte(LUX_SERIAL_STATUS);
        // serial_write_byte(BIT_BUSY);
    }
}

fn is_bit_set(value: u8, bit: u8) -> bool {
    (value & (1 << bit)) != 0
}

fn set_bit(value: &mut u8, bit: u8) {
    *value |= 1 << bit;
}

fn pull_from_serial_stack() {
    unsafe {
        if SERIAL_HEAD > SERIAL_TAIL {
            // zwalnianie bufora
            // let byte = SERIAL_BUFFER[(SERIAL_TAIL & 511) as usize];
            SERIAL_HEAD = 1;
        } 
    }
}

fn outb(port: u16, value: u8) {
    unsafe {
        Port::<u8>::new(port).write(value);
    }
}




fn serial_log(msg: &str) {
    let _ = writeln!(SerialWriter, "{}", msg);
}

#[derive(Copy, Clone)]
pub enum LuxPointer {
    Relative(i8),
    Absolute24(u32),
    Global64(u64),
}

impl LuxPointer {
    fn resolve(self, current: u64) -> u64 {
        match self {
            LuxPointer::Relative(offset) => (current as i128 + offset as i128) as u64,
            LuxPointer::Absolute24(addr) => addr as u64,
            LuxPointer::Global64(addr) => addr,
        }
    }
}
// 
#[repr(C, packed)]
pub struct LuxSymbol {
    pub header: u8,
    pub body: LuxPointer,
}

impl LuxSymbol {
    pub fn execute(&self, current_rip: u64) -> u64 {
        self.body.resolve(current_rip)
    }
}

pub struct  LuxPromise {
    pub status: u8,
    pub disk_lba: u64,
    pub ocean_target: u64,
    pub size_sectors: u64,
}
impl LuxPromise {
    // Sprawdza, czy obietnica została już spełniona (Present Bit w statusie)
    pub fn is_present(&self) -> bool {
        (self.status & 0b00000001) != 0
    }

    // "Materializacja": Wczytuje dane z LBA do Oceanu (Target)
    pub fn materialize(&mut self) {
        if !self.is_present() {
            // TODO dodać wywołanie sterownika dysku i odczyt danych
            // Tu wywołujemy Twój sterownik dysku (np. ATA/PCIe)
            // disk_read(self.disk_lba, self.ocean_target, self.size_sectors);
            
            // Po wczytaniu ustawiamy flagę PRESENT
            self.status |= 0b00000001;
            
            // LOG-LUX: "Obietnica LBA X spełniona pod adresem Y"
        }
    }
}

#[repr(C, packed)]
pub struct LuxEntity {
    pub id: u64,           // Twoje 1-7 (Unikalność 64-bit)
    pub promise: LuxPromise, // Obietnica materializacji (Dysk -> Ocean)
}

impl LuxPromise {
    pub fn new(disk_lba: u64, ocean_target: u64, size_sectors: u64) -> Self {
        LuxPromise {
            status: 0,
            disk_lba,
            ocean_target,
            size_sectors,
        }
    }
}

impl LuxEntity {
    // "Lux-Enlighten": Szukamy tylko tego, co niezbędne
    pub fn enlighten(&self) {
        // Tu logika, która patrzy na relacje i decyduje:
        // Czy wczytać 22KB kodu, czy 100MB obrazu?
    }
}

static mut IDT: InterruptDescriptorTable = InterruptDescriptorTable::new();

pub fn init_idt() {
    unsafe {
        IDT.page_fault.set_handler_fn(page_fault_handler);
        IDT.load();
    }
}

extern "x86-interrupt" fn page_fault_handler(
    stack_frame: InterruptStackFrame,
    error_code: PageFaultErrorCode,
) {
    use x86_64::registers::control::Cr2;

    let _ = write!(SerialWriter, "EXCEPTION: PAGE FAULT");
    let _ = write!(SerialWriter, "Accessed Address: {:?}", Cr2::read());
    let _ = write!(SerialWriter, "Error Code: {:?}", error_code);
    let _ = write!(SerialWriter, "Stack Frame: {:#?}", stack_frame);

    if !error_code.contains(PageFaultErrorCode::PROTECTION_VIOLATION) {
        let _ = write!(SerialWriter, "Błąd: strona nie jest obecna.");
    }

    loop {
        unsafe { asm!("hlt"); }
    }
}

#[link_section = ".text.startup"]
#[no_mangle]
pub extern "C" fn _start() -> ! {
    init_idt();
    serial_log("\n\nLux-7x512: pierwszy impuls");

    let symbol: LuxSymbol = LuxSymbol {
        header: 0b1000_0001,
        body: LuxPointer::Relative(8),
    };

    let target = symbol.execute(IMPULSE_BASE);
    let _ = write!(
        SerialWriter,
        "\nPoczątek symbolicznej podróży: 0x{:X}\n\n",
        target
    );
    write!(SerialWriter, "działadziałdziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziałaadziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziaładziała\n").ok();
    unsafe {
        let occupancy = SERIAL_HEAD - SERIAL_TAIL;
        let _ = write!(SerialWriter, "occupancy {} {} {}", occupancy, SERIAL_HEAD, SERIAL_BUFFER.len());
    }
    
    loop {
        unsafe { asm!("hlt"); }
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    let _ = writeln!(SerialWriter, "Panika: {:?}", info);
    loop {
        unsafe { asm!("hlt"); }
    }
}
