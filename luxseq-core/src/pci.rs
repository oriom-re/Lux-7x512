// Funkcja do odczytu konfiguracji PCI - potrzebna do skanowania urządzeń PCI i ich identyfikacji
fn pci_config_read(bus: u8, device: u8, function: u8, offset: u8) -> u16 {
    let port = 0xCF8;
    let address = (1 << 31) | ((bus as u32) << 16) | ((device as u32) << 11) | ((function as u32) << 8) | (offset as u32 & 0xFC);
    unsafe {
        let mut addr_port = Port::<u32>::new(port);
        addr_port.write(address);
        let mut data_port = Port::<u32>::new(0xCFC);
        let value = data_port.read();
        (value >> ((offset & 2) * 8)) as u16
    }
}


// Czytamy całe 32 bity, bo PCI tak kocha najbardziej
fn pci_config_read_u32(bus: u8, device: u8, function: u8, offset: u8) -> u32 {
    let address = (1 << 31) // bit 31 musi być ustawiony, żeby wskazać, że to jest adresowanie PCI

                | ((bus as u32) << 16) // bus w bitach 23-16 
                | ((device as u32) << 11) // device w bitach 15-11
                | ((function as u32) << 8) // function w bitach 10-8
                | (offset as u32 & 0xFC);   // offset w bitach 7-2 (musi być wielokrotnością 4, bo czytamy 32 bity)
    unsafe {
        //
        Port::<u32>::new(0xCF8).write(address); // najpierw ustawiamy adres, z którego chcemy czytać
        Port::<u32>::new(0xCFC).read()  // a potem odczytujemy wartość z portu danych
    }
}

// Teraz BAR wreszcie pokaże swoją prawdziwą twarz (u32)
fn pci_config_read_bar(bus: u8, device: u8, function: u8, bar_index: u8) -> u32 {
    let bar_offset = 0x10 + (bar_index * 4);
    pci_config_read_u32(bus, device, function, bar_offset)
}

fn pci_config_write(bus: u8, device: u8, function: u8, offset: u8, value: u32) {
    let port = 0xCF8;
    let address = (1 << 31) | ((bus as u32) << 16) | ((device as u32) << 11) | ((function as u32) << 8) | (offset as u32 & 0xFC);
    unsafe {
        let mut addr_port = Port::<u32>::new(port);
        addr_port.write(address);
        let mut data_port = Port::<u32>::new(0xCFC);
        data_port.write((value as u32) << ((offset & 2) * 8));
    }
}

// Skaner PCI
fn scan_pci() {
    for bus in 0..=255 {
        for device in 0..32 {
            for function in 0..8 {
                let id_block = pci_config_read_u32(bus, device, function, 0x00);
                let vendor_id = (id_block & 0xFFFF) as u16;
                let device_id = (id_block >> 16) as u16;
                if vendor_id != 0xFFFF {
                    
                    write!(SerialWriter, "Znaleziono urządzenie PCI: bus {}, device {}, function {}, vendor_id {:04X}, device_id {:04X}\n",
                        bus, device, function, vendor_id, device_id).ok();
                    // włączamy urządzenie, ustawiając bit 2 w rejestrze Command (offset 0x04)
                    // pci_config_write(bus, device, function, 0x04, 0x04);

                    // Odczyt BARów dla znalezionego urządzenia
                    for bar_index in 0..6 {

                        let bar_value = pci_config_read_bar(bus, device, function, bar_index);
                        if bar_value != 0 {
                            write!(SerialWriter, "BAR{}: {:08X}\n", bar_index, bar_value).ok();
                    }
                }
            }
        }
    }
}
}