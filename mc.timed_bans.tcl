##
# Timed Bans v1.0
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  requested by ting
#  This script will only run on eggdrop 1.5.5 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# Description
##
# This script enables you to have bans on certain channels enabled at different times
# of the day, and even different days.
##

##
# The history log has been moved to the very bottom of this script.
##

##
# COMMANDS (dcc)
##
# +timed_ban [channel|'global'] <banmask> <<start hour>':'<start minute><'a'|'p'>'-'<stop hour>':'<start minute><'a'|'p'>> <day1[','<day2[','<dayN>]>]> <reason>
# 	This adds a timed ban to the timed bans banlist.  If you do not supply a valid
#   channel or global, it will default to the channel your console is in.  If the
#   channel your console is in, it will default to global.
# 	Examples:
# 		.+timed_ban #abc123 *!*@*.aol.com 7:00p-11:00p Monday,Tuesday,Wednesday,Thursday,Friday Ahh, the aol users are home from work.
# 		.+timed_ban #abc123 *!*@*.aol.com 12:00a-11:59p Saturday,Sunday The AOLers have the weekend off I see.
#
# -timed_ban <timed_ban_number>
# 	This will remove a timed ban previously added.  Each time you add a timed ban, it
# 	will give you the number it was added under.  You can also fined the timed ban
# 	number by pulling the list of timed bans.
#
# timed_bans [channel|'global'|'all']
# 	This will display a list of timed bans.  If you supply an invalid channel, it
#   will default to all.  If you do not supply a channel, it will default to the
#   channel set to your console.  If your console channel is not a valid channel, it
#   will then default to all.
##

##
# Settings
##
#

# What flagged users should only be allowed to perform the dcc commands listed
# above?  Flag format is "<global>|<channel>".  Set this to "-|-" to give all valid
# users access.
set mc_tb(access) "m|m"

# What flagged users do you want to exempt from this script's banning?  Flag format
# is "<global>|<channel>".  Set this to "" to exempt no one.
set mc_tb(exempt) "nb|n"

# What file do you want to have this script save it's timed ban entries to?
set mc_tb(database) ".timed_bans.dat"


## SVS Client (Script Version Service) v3.1 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if there
# is a newer version of this script available.  This will only notify users of the ne
# version via a note.  It's up to the owner of the bot to download, adjust settings
# then install the script.

# If a newer version is found, whom do you want to notify?  The notification is sent
# via a note.  Seperate each user with a space, or set this to "" to disable SVS
# notification.  For those whom know TCL; do not put this in list format, keep it in
# string format.
set mc_tb(svs:notify) "MC_8"

# Would you like to restrict the concept of a new version to stable releases only?
#   0 = No, inform of both stable and beta release versions.
#   1 = Yes, inform of only stable release versions.
set mc_tb(svs:mode) 0


##

##
# Edit no further, tcl coding below.
##

#Script:mc_tb

set mc_tb(script)      "Timed Bans"
set mc_tb(version)     "v1.0"
set mc_tb(svs:script)  "001000000000"
set mc_tb(svs:version) "timed_bans"
set mc_tb(svs:server)  "mc.svs.purehype.net"
set mc_tb(svs:port)    "81"
set mc_tb(svs:get)     "/index.tcl"
set mc_tb(svs:query)   \
	"svs=$mc_tb(svs:script)&version=$mc_tb(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_tb(script) $mc_tb(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}


# Error system, v3.0
proc mc:tb:error {command error arg} {
	global mc_tb version lastbind errorInfo
	putlog "Error in script $mc_tb(script) $mc_tb(version)."
	putlog "    Error System: v3.0"
	putlog "       Last Bind: [expr {[info exists lastbind] ? $lastbind : "-NULL-"}]"
	putlog "         Command: $command"
	putlog "       Arguments: $arg"
	putlog "       Error Msg: $error"
	putlog "    Egg. Version: [expr {[info exists version] ? $version : "-NULL-"}]"
	putlog "     TCL Version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
	putlog "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
	putlog "*** Please include ALL info. in the bug report, including the next(s)."
	error $errorInfo
}

proc mc:tb:errchk {command arg} {
	if {![catch {eval $command $arg} return]} {return $return}
	mc:tb:error $command $return $arg
	return 0
}
# ^


;# Ensure settings are correct.
;foreach "temp(a) temp(b)" [list access m|m database .timed_bans.dat] {
;	if {![info exists mc_tb($temp(a))] || ($mc_tb($temp(a)) == "")} {
;		set mc_tb($temp(a)) $temp(b)
;	}
;}
;if {($mc_tb(access) == "") || ($mc_tb(access) == "|")} {
;	set mc_tb(access) "-|-"
;} elseif {![string match *|* $mc_tb(access)]} {
;	append mc_tb(access) "|-"
;} elseif {[string index $mc_tb(access) 0] == "|"} {
;	set mc_tb(access) "-$mc_tb(access)"
;}
;if {$mc_tb(exempt) == "|"} {
;	set mc_tb(exempt) ""
;} elseif {![string match *|* $mc_tb(exempt)]} {
;	append mc_tb(exempt) "|-"
;} elseif {[string index $mc_tb(exempt) 0] == "|"} {
;	set mc_tb(exempt) "-$mc_tb(exempt)"
;}

bind dcc - +timed_bans mc:tb:+timed_bans
proc mc:tb:+timed_bans {handle idx arg} {mc:tb:dcc + $handle $idx $arg}

bind dcc - -timed_bans mc:tb:-timed_bans
proc mc:tb:-timed_bans {handle idx arg} {mc:tb:dcc - $handle $idx $arg}

bind dcc - timed_bans mc:tb:timed_bans
proc mc:tb:timed_bans {handle idx arg} {mc:tb:dcc "" $handle $idx $arg}

proc mc:tb:dcc {command handle idx arg} {
	return [mc:tb:errchk mc:tb:dcc_ [list $command $handle $idx $arg]]
}
proc mc:tb:dcc_ {command handle idx arg} {
	global mc_tb

	set has_access 0
	if {$mc_tb(access) == "-|-"} {set has_access 1} \
	else {
		set global_flags [split $mc_tb(access) |]
		if {[matchattr $handle $global_flags|]} {
			set has_access 1
		}
	}

	set arg [mc:tb:2list $arg]
	switch -- $command {
		+ {

			if {[llength $arg] < 4} {
				set syntax {[channel|'global'] <banmask> <<start hour>':'<start minute>}
				append syntax {<'a'|'p'>'-'<stop hour>':'<start minute><'a'|'p'>> <day1[','}
				append syntax {<day2[','<dayN>]>]> <reason>}
				putdcc $idx "Usage: +timed_ban $syntax."
				return 0
			}

			set channel [lindex $arg 0]
			if {($channel != "global") && ![validchan $channel]} {
				set channel [lindex [console $idx] 0]
				if {($channel == "*") || (![validchan $channel])} {
					set channel "global"
				}; set index 0
			} else {set index 1}
			foreach name [list banmask time days] {
				set $name [lindex $arg $index]
				incr index
			}
			set reason [join [lrange $arg $index end]]

			if {!$has_access} {
				if {$channel == "global"} {
					putdcc $idx "$mc_tb(script): You do not have access to add globally."
					return 0
				}
				if {![matchattr $handle $mc_tb(access) $channel]} {
					putdcc $idx "$mc_tb(script): You do not have access to add for $channel."
					return 0
				}
			}

			set return \
				[mc:tb:list add [list ? $channel $banmask $time $days $reason $handle]]
			set return_arg [lindex $return 1]
			switch -- [lindex $return 0] {
				0 {
					putdcc $idx "$mc_tb(script): Entry added as number $return_arg."
					return 1
				}
				1 {
					set syntax "must be hh:mmAM/PM-hh:mmAM/PM"
					putdcc $idx "$mc_tb(script): Invalid time range '$return_arg', $syntax."
					return 0
				}
				2 {
					set syntax "must be 1-12"
					putdcc $idx "$mc_tb(script): Invalid start hour '$return_arg', $syntax."
					return 0
				}
				3 {
					set syntax "must be 0-59"
					putdcc $idx "$mc_tb(script): Invalid start minute '$return_arg', $syntax."
					return 0
				}
				4 {
					set syntax "must be 1-12"
					putdcc $idx "$mc_tb(script): Invalid stop hour '$return_arg', $syntax."
					return 0
				}
				5 {
					set syntax "must be 0-59"
					putdcc $idx "$mc_tb(script): Invalid stop minute '$return_arg', $syntax."
					return 0
				}
				6 {
					set syntax "must be any combination of "
					append syntax "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"
					putdcc $idx "$mc_tb(script): Invalid day '$return_arg', $syntax."
					return 0
				}
				7 {
					putdcc $idx "$mc_tb(script): Entry already exists as number $return_arg."
					return 0
				}
				ap {
					set syntax "and stop on am, that's a different day"
					putdcc $idx "$mc_tb(script): You cannot start on pm $syntax."
					return 0
				}
			}
		}
		- {
			# -timed_ban <timed_ban_number>

			set number [lindex $arg 0]
			if {$number == ""} {
				putdcc $idx "$mc_tb(script): Forget to supply the number you want to remove?"
				return 0
			}

			if {!$has_access} {
				set channel [mc:tb:list getchan $number]
				if {$channel == ""} {
					putdcc $idx "$mc_tb(script): No entry found for number $number."
					return 0
				}
				if {$channel == "global"} {
					putdcc $idx "$mc_tb(script): You do not have access to remove globally."
					return 0
				}
				if {![matchattr $handle $mc_tb(access) $channel]} {
					putdcc $idx \
						"$mc_tb(script): You do not have access to remove for $channel."
					return 0
				}
			}

			switch -- [mc:tb:list delete $number] {
				0 {
					putdcc $idx "$mc_tb(script): No entry found for number $number."
					return 0
				}
				1 {
					putdcc $idx "$mc_tb(script): Removed entry number $number."
					return 1
				}
			}
		}
		"" {
			# timed_bans [channel|'global'|'all']

			set channel [lindex $arg 0]
			if {($channel != "global") && ($channel != "all") && ![validchan $channel]} {
				set channel [lindex [console $idx] 0]
				if {($channel == "*") || (![validchan $channel])} {
					set channel "all"
				}
			}

			if {!$has_access} {
				if {$channel == "global"} {
					putdcc $idx "$mc_tb(script): You do not have access to view globally."
					return 0
				}
				if {$channel == "all"} {
					set syntax "global access required"
					putdcc $idx "$mc_tb(script): You do not have access to view all, $syntax."
					return 0
				}
				if {![matchattr $handle $mc_tb(access) $channel]} {
					putdcc $idx "$mc_tb(script): You do not have access to view for $channel."
					return 0
				}
			}

			putcmdlog "#$handle# timed_bans $channel"
			set current_time [clock format [clock seconds] -format "%I:%M%p %A"]
			putdcc $idx " --- Current bot time: $current_time"
			putdcc $idx "$mc_tb(script) listing for '$channel':"
			set give_space 0
			foreach entry [mc:tb:list list $channel] {
				set number [lindex $entry 0]
				set channel [lindex $entry 1]
				set banmask [lindex $entry 2]
				set time [lindex $entry 3]
				set days [lindex $entry 4]
				set reason [lindex $entry 5]
				set added_by [lindex $entry 6]
				set time_added [lindex $entry 7]

				set days [split $days ""]
				set days [mc:tb:replace -nocase -- $days [list 1 Monday     \
																					      			 2 Tuesday    \
																					      			 3 Wednesday  \
																					      			 4 Thursday   \
																							      	 5 Friday     \
																							      	 6 Saturday   \
																							      	 7 Sunday    ]]
				set days [join $days]

				if {[string match *day* [set time_added [mc:tb:ut2d $time_added]]]} {
					append time_added " ago"
				}

				if {$give_space} {putdcc $idx ""}
				putdcc $idx [format "%9s %s" "$channel:" "($number) $banmask"     ]
				putdcc $idx [format "%9s %s" ""          "      Time: $time"      ]
				putdcc $idx [format "%9s %s" ""          "      Days: $days"      ]
				putdcc $idx [format "%9s %s" ""          "    Reason: $reason"    ]
				putdcc $idx [format "%9s %s" ""          "  Added by: $added_by"  ]
				putdcc $idx [format "%9s %s" ""          "Time added: $time_added"]

				if {!$give_space} {set give_space 1}
			}

			return 0
		}
		default {error "Invalid command, '$command'."}
	}
}

bind mode - "% +o" mc:tb:mode:+o
proc mc:tb:mode:+o {nick uhost handle channel mode_change victim} {
	set pass [list $nick $uhost $handle $channel $mode_change $victim]
	return [mc:tb:errchk mc:tb:mode:+o_ $pass]
}
proc mc:tb:mode:+o_ {nick uhost handle channel mode_change victim} {
	global mc_tb
	if {![isbotnick $victim]} {return 0}

	foreach user [chanlist $channel] {
		mc:tb:join $user [getchanhost $user] [nick2hand $user] $channel
	}
	return 1

}

bind time - * mc:tb:time
proc mc:tb:time {args} {
	return [mc:tb:errchk mc:tb:time_ [list $args]]
}
proc mc:tb:time_ {args} {
	global mc_tb
	foreach channel [channels] {
		if {![mc:tb:list can_go $channel]} {continue}
		foreach user [chanlist $channel] {
			mc:tb:join $user [getchanhost $user] [nick2hand $user] $channel
		}
	}
}

bind join - * mc:tb:join
proc mc:tb:join {nick uhost handle channel} {
	return [mc:tb:errchk mc:tb:join_ [list $nick $uhost $handle $channel]]
}
proc mc:tb:join_ {nick uhost handle channel} {
	global mc_tb

	if {([isbotnick $nick]) || (![botisop $channel]) ||
	    (($mc_tb(exempt) != "") && ([matchattr $handle $mc_tb(exempt) $channel]))} {
		return 0
	}

	foreach entry "[mc:tb:list list global] [mc:tb:list list $channel]" {
		set number [lindex $entry 0]
		set banmask [lindex $entry 2]
		set time [lindex $entry 3]
		set days [lindex $entry 4]
		set reason [lindex $entry 5]
		set added_by [lindex $entry 6]
		set time_added [lindex $entry 7]
		# List format: number channel banmask time days reason added_by time_added

		if {![string match $banmask $nick!$uhost]} {continue}

		set regex {([0-9]?[0-9]):([0-9]?[0-9])(a|p)}
		append regex {-([0-9]?[0-9]):([0-9]?[0-9])(a|p)}
		if {![regexp -- $regex $time > start_h start_m start_s stop_h stop_m stop_s]} {
			error "Invalid saved time format, '$time'."
		}

		set time_now [clock format [clock seconds] -format "%H %M %w"]
		set time_now [split $time_now]
		set time_now_hour [string trimleft [lindex $time_now 0] 0]
		set time_now_minute [string trimleft [lindex $time_now 1] 0]
		set time_now_day [lindex $time_now 2]
		set time_now_eval [expr ($time_now_hour*60)+$time_now_minute]

		set name_list [list time_now time_now_hour time_now_minute time_now_day ]
		append name_list " [list time_now_eval start_h start_m stop_h stop_m]"
		foreach name $name_list {
			set $name [string trimleft [set $name] 0]
		}

		set start_eval [expr ($start_h*60)+$start_m+(60*[expr {$start_s == "p"?12:1}])]
		set stop_eval [expr ($stop_h*60)+$stop_m+(60*[expr {$stop_s == "p"?12:1}])]

		if {($time_now_eval < $start_eval) || ($time_now_eval > $stop_eval) ||
		    (![string match *$time_now_day* $days])} {continue}



		# Using putserv instead of pushmode for the ban to ensure the ban and kick are on
		# the same queue.
		putserv "MODE $channel +b $banmask"
		putserv "KICK $channel $nick :($number) $added_by: $reason"

		set syntax "timed ban number $number"
		putlog "$mc_tb(script): Kicking and banning $nick from $channel, $syntax."
		return 1
	}
	return 0
}

bind evnt - save mc:tb:evnt:save
proc mc:tb:evnt:save {type} {return [mc:tb:errchk mc:tb:evnt:save_ [list $type]]}
proc mc:tb:evnt:save_ {type} {mc:tb:list save}

proc mc:tb:list {command {arg ""}} {
	global mc_tb botnet-nick
	set array_name [list :: list]
	if {![info exists mc_tb($array_name)]} {set mc_tb($array_name) ""}
	switch -- $command {
		add {

			set index 0
			foreach name [list number channel banmask time days reason handle time_added] {
				set $name [lindex $arg $index]
				incr index
			}
			set time [string tolower $time]
			if {$time_added == ""} {set time_added [clock seconds]}

			set regex {([0-9]?[0-9]):([0-9]?[0-9])(am?|pm?)}
			append regex {-([0-9]?[0-9]):([0-9]?[0-9])(am?|pm?)}
			if {![regexp -- $regex $time > start_h start_m start_s stop_h stop_m stop_s]} {
				return [list 1 $time]
			}
			if {(!$start_h) || ($start_h > 12)} {
				return [list 2 $start_h]
			}
			if {$start_m > 59} {
				return [list 3 $start_m]
			}
			set start_s [string index $start_s 0]
			if {(!$stop_h) || ($stop_h > 12)} {
				return [list 4 $stop_h]
			}
			if {$stop_m > 59} {
				return [list 5 $stop_m]
			}
			set stop_s [string index $stop_s 0]
			if {($start_s == "p") && ($stop_s == "a")} {
				return [list ap]
			}
			set time "$start_h:$start_m$start_s-$stop_h:$stop_m$stop_s"

			set days [mc:tb:replace -nocase -- $days [list Monday    1 \
			                                               Tuesday   2 \
			                                               Wednesday 3 \
			                                               Thursday  4 \
			                                               Friday    5 \
			                                               Saturday  6 \
			                                               Sunday    7]]
			set days_ ""
			foreach day [split $days ,] {
				if {![regexp -- {[1-7]} $day]} {return [list 6 $day]}
				if {[lsearch -exact $days_ $day] == -1} {lappend days_ $day}
			}
			set days [join [lsort -dictionary $days_] ""]

			# By now, we should have these variables validated:
			# channel banmask time days reason

			set return [mc:tb:list exists [list $channel $banmask $time $days]]
			set return_a [lindex $return 0]
			if {$return_a} {return [list 7 $return_a]}
			set return_b [lindex $return 1]

			foreach name [list channel banmask time days] {
				set $name [string tolower [set $name]]
			}

			if {$number == "?"} {set number $return_b}
			lappend mc_tb($array_name) [list $number $channel $banmask $time $days \
				$reason $handle $time_added]
			set mc_tb($array_name) [lsort -dictionary -index 0 $mc_tb($array_name)]

			if {$channel == "global"} {set channels [channels]} \
			else {set channels [list $channel]}
			foreach channel $channels {
				foreach user [chanlist $channel] {
					mc:tb:join $user [getchanhost $user] [nick2hand $user] $channel
				}
			}

			return [list 0 $return_b]
		}
		delete {
			set number $arg

			set found 0
			set new_list ""
			foreach entry [mc:tb:list list all] {
				if {[lindex $entry 0] != $number} {
					lappend new_list $entry
				} else {set found 1}
			}
			if {!$found} {return 0}

			set mc_tb($array_name) $new_list
			set mc_tb($array_name) [lsort -dictionary -index 0 $mc_tb($array_name)]

			return 1
		}
		can_go {
			# In: channel

			set channel [string tolower $arg]

			if {![botisop $channel]} {return 0}

			foreach entry "[mc:tb:list list global] [mc:tb:list list $channel]" {
				set number [lindex $entry 0]
				set banmask [lindex $entry 2]
				set time [lindex $entry 3]
				set days [lindex $entry 4]
				set reason [lindex $entry 5]
				set added_by [lindex $entry 6]
				set time_added [lindex $entry 7]

				set rgx {([0-9]?[0-9]):([0-9]?[0-9])(a|p)}
				append rgx {-([0-9]?[0-9]):([0-9]?[0-9])(a|p)}
				if {![regexp -- $rgx $time > start_h start_m start_s stop_h stop_m stop_s]} {
					error "Invalid saved time format, '$time'."
				}

				set time_now [clock format [clock seconds] -format "%H %M %w"]
				set time_now [split $time_now]
				set time_now_hour [lindex $time_now 0]
				set time_now_minute [lindex $time_now 1]
				set time_now_day [lindex $time_now 2]

				set name_list [list time_now time_now_hour time_now_minute time_now_day ]
				append name_list " [list time_now_eval start_h start_m stop_h stop_m]"
				foreach name $name_list {
					set $name [string trimleft [set $name] 0]
				}

				set time_now_eval [expr ($time_now_hour*60)+$time_now_minute]
				set start_eval \
					[expr ($start_h*60)+$start_m+(60*[expr {$start_s == "p"?12:1}])]
				set stop_eval [expr ($stop_h*60)+$stop_m+(60*[expr {$stop_s == "p"?12:1}])]

				if {($time_now_eval < $start_eval) || ($time_now_eval > $stop_eval) ||
						(![string match *$time_now_day* $days])} {continue}

				return 1
			}
		  return 0
		}
		exists {
			# In: channel banmask time days
			# List format: <0 next_number>|<current_number>

			set index 0
			foreach name [list channel banmask time days] {
				set $name [string tolower [lindex $arg $index]]
				incr index
			}

			# The logic for finding the lowest free number will only work if the list
			# stays sorted via dictionary upon the timed ban's number.
			set number 1
			set current_number 0
			set stop_counting 0
			foreach entry [mc:tb:list list all] {
				set current_number [lindex $entry 0]
				if {([lindex $entry 1] == $channel) &&
				    ([lindex $entry 2] == $banmask) &&
				    ([lindex $entry 3] == $time) &&
				    ([lindex $entry 4] == $days)} {
					return [list $current_number]
				}
				if {!$stop_counting} {
					if {$number == $current_number} {
						incr number
					} else {
						set next_number $number
						set stop_counting 1
					}
				}
			}
			if {!$stop_counting} {set next_number [expr $current_number+1]}

			return [list 0 $next_number]
		}
		list {
			# List format: number channel banmask time days reason added_by time_added
			# In: channel|'all'|'global'

			set channel [string tolower [lindex $arg 0]]

			if {$channel == "all"} {return $mc_tb($array_name)}

			set return ""
			foreach entry $mc_tb($array_name) {
				if {[lindex $entry 1] == $channel} {lappend return $entry}
			}

			return $return
		}
		getchan {
			# In: number

			foreach entry $mc_tb($array) {
				if {[lindex $entry 0] == $arg} {return [lindex $entry 1]}
			}
			return ""
		}
		save {
			if {$arg != "quiet"} {putloglev o * "Writing $mc_tb(script) file..."}

			set io [open $mc_tb(database) w]
			puts $io "#v1:$mc_tb(script):$mc_tb(version):${botnet-nick}:[clock seconds]"
			foreach entry [mc:tb:list list all] {
				puts $io $entry
			}
			close $io
		}
		load {
			if {$arg != "quiet"} {putloglev o * "Loading $mc_tb(script) file..."}

			set mc_tb($array_name) ""
			if {![file exists $mc_tb(database)]} {close [open $mc_tb(database) w]} \
			else {
				set io [open $mc_tb(database) r]
				set start 0
				while {![eof $io]} {
					gets $io line
					if {!$start} {
						if {[string index $line 0] != "#"} {continue}
						set line [split $line :]
						set saved_db_version [string range [lindex $line 0] 1 end]
						set saved_script [lindex $line 1]
						set saved_version [lindex $line 2]
						set saved_botnet-nick [lindex $line 3]
						set saved_time [lindex $line 4]
						set start 1
						continue
					}
					# List format: number channel banmask time days reason added_by time_added

					set index 0
					set items \
						[list number channel banmask time days reason added_by time_added]
					foreach item $items {
						set $item [lindex $line $index]
						incr index
					}

					set add [list $number $channel $banmask $time $days $reason $added_by \
						$time_added]
					set return [mc:tb:list add $add]
					set return_arg [lindex $return 1]
					set load_skip "Load skipping number $number;"
					switch -- [lindex $return 0] {
						0 {
							# Record loaded successfully.
						}
						1 {
							set syntax "Invalid time range '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						2 {
							set syntax "Invalid start hour '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						3 {
							set syntax "Invalid start minute '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						4 {
							set syntax "Invalid stop hour '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						5 {
							set syntax "Invalid stop minute '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						6 {
							set syntax "Invalid day '$return_arg'"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						7 {
							set syntax "Entry already exists as number $return_arg"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
						ap {
							set syntax "You cannot start on pm and stop on am"
							putloglev d * "$mc_tb(script): $load_skip $syntax."
						}
					}
				}
				close $io
			}
		}
		default {error "Invalid command, '$command'."}
	}
}

# in: unixtime
#out: x day(s) || hh:mm
proc mc:tb:ut2d {time} {
	set diff [string trimleft [expr [clock seconds]-$time] -]
	if {[set d [expr $diff/60/60/24]] != "0"} {
		if {$d == "1"} {set s ""} else {set s s}
		append d day$s
	} else {
		set d [clock format $time -format %H:%M]
	}; return $d
}


## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:tb:badargs {{args ""}} {
	if {[llength $args] < 4} {
		error {
			wrong # args: should be "mc:tb:badargs args min_llength max_llength argNames"
		}
	}

	set index 0
	foreach varName [list args min max names] {
		set check_$varName [lindex $args $index]
		incr index
	}

	if {[regexp -- {([^0-9])} $check_min -> bad]} {
		error "bad number \"$bad\" in: $check_min"
	}
	if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
		error "bad number \"$bad\" in: $check_max"
	}

	# Make sure $check_args is in list format, if not then make it so.
	# Were not going to use 2list here, don't want to evoke a 'too many nested calls
	# to Tcl_EvalObj' error since '2list' uses on this proc.
	if {[catch {llength $check_args} llength]} {
		set check_args [split $check_args]
		set llength $check_args
	}

	if {($llength < $check_min) || (($llength != "end") && ($llength > $check_max))} {
		if {[info level] == "1"} {return 1}
		error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
	}; return 0
}

# 2list <text>
#     version:
#       v1.0
proc mc:tb:2list {{args ""}} {
	mc:tb:badargs $args 1 1 "text"
	mc:tb:unlist $args text

	return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:tb:unlist {{args ""}} {
	mc:tb:badargs $args 1 end "argsList ?varName varName ...?"
	set argList [lindex $args 0]
	set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
	set argNames [lrange $args 1 end]
	if {![llength $argNames]} {
		return [expr {(![catch {llength $argList}])?
			[join $argList]:$argList}]
	}
	for {set index 0} {$index < [llength $argNames]} {incr index 1} {
		set argName     [lindex $argNames $index]
		set argListItem [lindex $argList  $index]

		set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
		set setTo   [lindex $argName_ 1]
		set argName [lindex $argName_ 0]

		if {$argName == ""} {continue}

		upvar 1 $argName var

		if {[expr $index+1] > [llength $argList]} {
			if {[llength $argName_] == "2"} {set var $setTo}
		} else {
			if {$argName == "args"} {
				set var [lrange $argList $index end]
				incr index [expr [llength $var]-1]
			} else {set var $argListItem}
		}
	}; return $index
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:tb:replace {{args ""}} {
	mc:tb:badargs $args 2 4 "?switches? text substitutions"
	set switches ""
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
		if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
			error "bad switch \"$arg\": must be -nocase, or --"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
	set text [lindex $args $i]
	set substitutions [lindex $args [expr $i+1]]
	mc:tb:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

	# Check to see if $substitutions is in list format, if not make it so.
	set substitutions [mc:tb:2list $substitutions]

	if {[info tclversion] >= "8.1"} {
		return [expr {($nocase)?
			[string map -nocase $substitutions $text]:
			[string map $substitutions $text]}]
	}

	set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
	foreach {a b} $substitutions {
		regsub -all -- $re_syntax $a {\\\1} a
		if {$nocase} {regsub -all -nocase -- $a $text $b text} \
		else {regsub -all -- $a $text $b text}
	}; return $text
}

## End of More Tools quick procs.


mc:tb:list load quiet


## SVS v3.1
set mc_tb(svs:client_version) "v3.1"
if {![info exists mc_tb(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_tb(svs:mode)]} {
	set mc_tb(svs:mode) 0
}
if {![info exists mc_tb(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_tb(svs:notify) $owner
}

bind time - "00 00 *" mc:tb:do_svs
proc mc:tb:do_svs {{args ""}} {
	global mc_tb
	mc:tb:do_svs_ $mc_tb(svs:server) $mc_tb(svs:port) $mc_tb(get)
}

proc mc:tb:do_svs_ {svs_server svs_port svs_get} {
	global mc_tb tcl_platform
	if {[catch {
	        socket -async $svs_server $svs_port
	           } sid]} {
		putloglev d * "$mc_tb(script): SVS socket error: $sid"
		return 1
	}

	# This block of code is to get a standard User-Agent line of information, as
	# proposed in http://www.mozilla.org/build/revised-user-agent-strings.html
	foreach array_name [list platform os osVersion machine] {
		set temp($array_name) [lindex [array get tcl_platform $array_name] 1]
	}
	switch -- $temp(platform) {
		windows {
			switch -- $temp(os) {
				Windows {set temp(2) Win$temp(osVersion)}
				"Windows 95" {
					if {$temp(osVersion) < "4.10"} {
						set temp(2) Win95
					} else {
						set temp(2) Win98
					}
				}
				"Windows 98" {set temp(2) Win98}
				"Windows NT" {
					if {$temp(osVersion) >= "5.0"} {
						set temp(2) "Windows NT $temp(osVersion)"
					} else {
						set temp(2) WinNT$temp(osVersion)
					}
				}
				default {
					set temp(2) "$temp(os) $temp(osVersion)"
				}
			}
		}
		unix {
			set temp(2) "unix $temp(machine)"
		}
		macintosh {
			set temp(2) $temp(machine)
		}
		default {
			set temp(2) "$temp(os) $temp(osVersion) $temp(machine)"
		}
	}
	set temp(user_agent) "Mozilla/5.001 ($temp(platform); U; $temp(2); en) "
	append temp(user_agent) "Gecko/25250101 $mc_tb(svs:script)/"
	append temp(user_agent) "$mc_tb(svs:version) SVS_Client/"
	append temp(user_agent) "$mc_tb(svs:client_version)"
	# ^

	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:tb:svs_talk $sid timeout $svs_server $svs_port"]
	fileevent $sid readable "mc:tb:svs_talk $sid $tout"
	puts $sid "GET $svs_get?$mc_tb(svs:query) HTTP/1.0\
	         \nHost: $svs_server:$svs_port\
	         \nUser-Agent: $temp(user_agent)\n"
	flush $sid
}

proc mc:tb:svs_talk {sid tout {svs_server ""} {svs_port ""}} {
	global mc_tb
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$svs_server:$svs_port"
		putloglev d * \
			"$mc_tb(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_tb($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_tb($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_tb($array)]} {
		if {$get == ""} {set mc_tb($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		200 {
			set temp(host) [lindex $get 1]
			set temp(port) [lindex $get 2]
			set temp(get) [lindex $get 3]
			set temp(cache) "$temp(host) at $temp(port)"
			putloglev d * "$mc_tb(script): SVS is being redirected to $temp(cache)."
			mc:tb:do_svs_ $temp(host) $temp(port) $temp(get)
			close $sid
			return 200
		}
		003 {
			set temp(reply) [lrange $get 1 end]
			for {set number 0} {$number <= 5} {incr number} {
				set temp(reply:$number) [lindex $temp(reply) $number]
			}
			if {$temp(reply:0) != $mc_tb(svs:script)} {
				set temp(1) "wanted $mc_tb(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_tb(script): SVS Error: $temp(1)"
				unset mc_tb($array)
				close $sid
				return -3
			}
			if {$mc_tb(svs:mode)} {
				set temp(svs:version) [string range $mc_tb(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_tb(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_tb(version) temp(note)
				foreach temp(to) [split $mc_tb(svs:notify) ",; "] {
					if {[string trim $temp(to)] == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_tb(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_tb(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_tb($array)
			close $sid
			return 2
		}
	}
}
## ^


putlog "$mc_tb(script) $mc_tb(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v1.0 (10.09.02)
#  MC_8 -      - Upgraded SVS Client.  v3.0.1 -> v3.1
#  MC_8 - ting - Fixed '... invalid octal number'.  [Bug: 173]
#  MC_8 - ting - Inital script.
##