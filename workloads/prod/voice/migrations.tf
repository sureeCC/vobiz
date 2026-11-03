moved {
  from = module.instances
  to   = module.voice_vm.module.instances
}
moved {
  from = module.templates
  to   = module.voice_vm.module.templates
}
moved {
  from = module.voice_identity
  to   = module.voice_vm.module.voice_identity
}
moved {
  from = data.google_compute_subnetwork.voice
  to   = module.voice_vm.data.google_compute_subnetwork.voice
}
moved {
  from = google_compute_address.voice
  to   = module.voice_vm.google_compute_address.voice
}
