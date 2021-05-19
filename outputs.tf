output "VM_IPs" {
  value = azurerm_windows_virtual_machine.node.*.public_ip_addresses
}

