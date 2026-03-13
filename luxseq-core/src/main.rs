#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

use core::{arch::asm, fmt::Write, panic::PanicInfo};
use x86_64::instructions::port::Port;
use x86_64::structures::idt::{InterruptDescriptorTable, InterruptStackFrame, PageFaultErrorCode};

const SERIAL_COM1: u16 = 0x3F8;
const IMPULSE_BASE: u64 = 0x00;

struct SerialWriter;

impl Write for SerialWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for byte in s.bytes() {
            serial_write_byte(byte);
        }
        Ok(())
    }
}

fn serial_write_byte(byte: u8) {
    unsafe {
        let mut status = Port::<u8>::new(SERIAL_COM1 + 5);
        while status.read() & 0x20 == 0 {}
        Port::<u8>::new(SERIAL_COM1).write(byte);
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
