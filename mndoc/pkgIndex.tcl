if {![package vsatisfies [package require Tcl] 8.6-]} {return}
package ifneeded mndoc 0.14.2 [list source [file join $dir mndoc.tcl]]
package ifneeded mndoc::mndoc 0.14.2 [list source [file join $dir mndoc.tcl]]
