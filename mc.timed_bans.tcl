##
# Timed Bans v1.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug?  http://mc.purehype.net/bugzilla/
##

##
# Description
##
# This script enables you to have bans on certain channels enabled at different
# times of the day, and even different days.
##

##
# Commands (dcc)
##
# +timed_ban [channel|'global'] <banmask> <time> <days> <reason>
#   This adds a timed ban to the timed bans banlist.  If you do not supply a
#   valid channel or global, it will default to the channel your console is in.
#   If the channel your console is in is invalid, it will default to global.
#   Global means it is active on all channels.
#   <time> is in such a format:
#     <start hour>:<start minute><am/pm>-<stop hour>:<stop minute><am/pm>
#   <days> is in such a format:
#     day1[,day2[,dayN]]
#   Examples:
#     +timed_ban #abc123 *!*@*.aol.com 7:00p-11:00p 
#       Monday,Tuesday,Wednesday,Thursday,Friday Ahh, the aol users are home
#       from work.
#     +timed_ban #abc123 *!*@*.aol.com 12:00a-11:59p Saturday,Sunday The AOLers
#       have the weekend off I see.
#
# -timed_ban <number>
#   This will remove a timed ban.  Each time you add a timed ban, it will give
#   you the number it was added under.  You can also fined the timed ban number
#   by pulling the list of timed bans.
#
# timed_bans [channel|'global'|'all']
#   This will display a list of timed bans. If you supply an invalid channel, it
#   will default to all. If you do not supply a channel, it will default to the
#   channel set to your console. If your console channel is not a valid channel,
#   it will then default to all.
##

##
# Configuration
##
#

# What flagged users should be allowed to perform the dcc commands listed above?
# Flag format is "<global>|<channel>".  Set this to "-|-" to give all valid
# users access.
set mc_tb(:config:access) "m|m"

# What flagged users do you want to exempt from this script's banning?  Flag
# format is "<global>|<channel>".  Set this to "" to exempt no one.
set mc_tb(:config:exempt) "nb|n"

# The script saves information in a file, where and what do you want the file to
# be called?
set mc_tb(:config:database) "./.timed_bans.dat"


## SVS Client (Script Version Service) v4.0.4 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_tb(:config:svs:enable) 1

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

#Script:mc_tb

## SVS insert (pre code)
catch {unset temp}
set mc_tb(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_tb :config:*] {
  lappend mc_tb(info:vars) [list $temp(name) $temp(value)]
}
set mc_tb(info:loc) [info script]
array set mc_tb [list \
  script                 "Timed Bans" \
  version                "v1.1" \
  svs:script             "001001000000" \
  svs:version            "timed_bans" \
  svs:client_version     "v4.0.4" \
  svs:client_svs_version "004000004000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "81" \
  svs:get                "/index.tcl"]
set mc_tb(svs:query)    "svs=$mc_tb(svs:script)&"
append mc_tb(svs:query) "version=$mc_tb(svs:version)&"
append mc_tb(svs:query) \
  "svs_version=$mc_tb(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_tb(script) $mc_tb(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag)  will not work with eggdrop $version."
  putloglev o * "$temp(tag)  not loaded."
  return 1
}
## ^

# Error system, v3.1
proc mc:tb:error {command error arg} {
  global mc_tb version lastbind errorInfo
  putloglev o * "Error in script $mc_tb(script) $mc_tb(version)."
  putloglev o * "    Error System: v3.0"
  putloglev o * \
    "       Last Bind: [expr {[info exists lastbind]?$lastbind:"-NULL-"}]"
  putloglev o * "         Command: $command"
  putloglev o * "       Arguments: $arg"
  putloglev o * "       Error Msg: $error"
  putloglev o * \
    "    Egg. Version: [expr {[info exists version]?$version:"-NULL-"}]"
  putloglev o * "     TCL Version: [info tclversion]"
  putloglev o * "  TCL Patchlevel: [info patchlevel]"
  putloglev o * "*** Please submit this bug so MC_8 can fix it.  Visit"
  putloglev o * \
    "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
  putloglev o * \
    "*** Please include ALL info. in the bug report, including the next(s)."
  error $errorInfo
}

proc mc:tb:errchk {command arg} {
  lappend ::lastCommand "$command $arg"
  set ::lastCommand\
    [lrange $::lastCommand [expr [llength $::lastCommand]-5] end]
  if {![catch {eval $command $arg} return]} {return $return}
  mc:tb:error $command $return $arg
  return 0
}
# ^

bind dcc - +timed_bans mc:tb:+timed_bans
proc mc:tb:+timed_bans {handle index arg} {
  mc:tb:dcc + $handle $index $arg
  return 0
}

bind dcc - -timed_bans mc:tb:-timed_bans
proc mc:tb:-timed_bans {handle index arg} {
  mc:tb:dcc - $handle $index $arg
  return 0
}

bind dcc - timed_bans mc:tb:timed_bans
proc mc:tb:timed_bans {handle index arg} {
  mc:tb:dcc "" $handle $index $arg
  return 0
}

proc mc:tb:dcc {command handle index arg} {
  return [mc:tb:errchk mc:tb:dcc_ [list $command $handle $index $arg]]
}
proc mc:tb:dcc_ {command handle index arg} {
  global mc_tb

  set flags_split [split $mc_tb(:config:access) |]
  if {[set global_flags [lindex $flags_split 0]] == ""} {
    set global_flags -
  }
  if {[set channel_flags [lindex $flags_split 1]] == ""} {
    set channel_flags -
  }
  set flags $global_flags|$channel_flags
  
  set arg [split $arg]
  switch -- $command {
    "+" {
      set log_lev_c "+timed_ban [join $arg]"

      set channel [lindex $arg 0]
      if {($channel != "global") && ![validchan $channel]} {
        set channel [lindex [console $index] 0]
        if {![validchan $channel]} {set channel "global"}
        set idx 0
      } else {set idx 1}
      foreach name [list banmask time days] {
        set $name [lindex $arg $idx]
        incr idx
      }
      set reason [join [lrange $arg $index end]]
      
      if {($channel == "global") && ![matchattr $handle $flags]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index "$mc_tb(script): You do not have access to add globally."
        return 0
      }
      if {[validchan $channel] && ![matchattr $handle $flags $channel]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index \
          "$mc_tb(script): You do not have access to add in $channel."
        return 0
      }
      
      if {[llength $arg] < 4} {
        set syntax {[channel|'global'] <banmask> <<start hour>:<start minute>}
        append syntax {<am/pm>-<stop hour>:<start minute><am/pm>>}
        append syntax {<day1[,day2[,dayN]]> <reason>}
        putloglev c * "#$handle# (invalid syntax) $log_lev_c"
        putdcc $index "Usage: +timed_ban $syntax."
        return 0
      }

      set return \
        [mc:tb:list add [list ? $channel $banmask $time $days $reason $handle]]
      set return_arg [lindex $return 1]
      switch -- [lindex $return 0] {
        
        "0" {
          putloglev c * "#$handle# $log_lev_c"
          putdcc $index "$mc_tb(script): Entry added as number $return_arg."
          return 1
        }
        
        "1" {
          set syntax "must be hh:mmAM/PM-hh:mmAM/PM"
          putloglev c * "#$handle# (invalid time range) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Invalid time range '$return_arg', $syntax."
          return 0
        }
        
        "2" {
          set syntax "must be 1-12"
          putloglev c * "#$handle# (invalid start hour) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Invalid start hour '$return_arg', $syntax."
          return 0
        }
        
        "3" {
          set syntax "must be 0-59"
          putloglev c * "#$handle# (invalid start minute) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Invalid start minute '$return_arg', $syntax."
          return 0
        }
        
        "4" {
          set syntax "must be 1-12"
          putloglev c * "#$handle# (invalid stop hour) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Invalid stop hour '$return_arg', $syntax."
          return 0
        }
        
        "5" {
          set syntax "must be 0-59"
          putloglev c * "#$handle# (invalid start minute) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Invalid stop minute '$return_arg', $syntax."
          return 0
        }
        
        "6" {
          set syntax "must be any combination of "
          putloglev c * "#$handle# (invalid day) $log_lev_c"
          append syntax \
            "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"
          putdcc $index "$mc_tb(script): Invalid day '$return_arg', $syntax."
          return 0
        }
        
        "7" {
          putloglev c * "#$handle# (entry already exists) $log_lev_c"
          putdcc $index \
            "$mc_tb(script): Entry already exists as number $return_arg."
          return 0
        }
        
        "ap" {
          set syntax "and stop on am, that's a different day"
          putloglev c * "#$handle# (failed, pm start am stop) $log_lev_c"
          putdcc $index "$mc_tb(script): You cannot start on pm $syntax."
          return 0
        }
        
      }
    }
    
    "-" {
      set log_lev_c "-timed_ban [join $arg]"
      
      set number [lindex $arg 0]
      if {$number == ""} {
        putloglev c * "#$handle# (invalid syntax) $log_lev_c"
        putdcc $index \
          "$mc_tb(script): Syntax: -timed_ban <number>"
        return 0
      }

      set channel [mc:tb:list getchan $number]
      if {$channel == ""} {
        putloglev c * "#$handle# (invalid number) $log_lev_c"
        putdcc $index "$mc_tb(script): No entry found for number $number"
        return 0
      }
      if {($channel == "global") && ![matchattr $handle $flags]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index \
          "$mc_tb(script): You do not have access to remove globally."
        return 0
      }
      if {[validchan $channel] && ![matchattr $handle $flags $channel]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index \
          "$mc_tb(script): You do not have access to remove in $channel."
        return 0
      }
      
      switch -- [mc:tb:list delete $number] {
        
        "0" {
          putloglev c * "#$handle# (invalid number) $log_lev_c"
          putdcc $index "$mc_tb(script): No entry found for number $number."
          return 0
        }
        
        "1" {
          putloglev c * "#$handle# $log_lev_c"
          putdcc $index "$mc_tb(script): Removed entry number $number."
          return 1
        }
        
      }
    }
    "" {
      set log_lev_c "-timed_ban [join $arg]"

      set channel [lindex $arg 0]
      if {($channel != "global") &&
          ($channel != "all") &&
          ![validchan $channel]} {
        set channel [lindex [console $index] 0]
        if {![validchan $channel]} {set channel "all"}
      }

      if {(($channel == "global") || ($channel == "all")) &&
          ![matchattr $handle $flags]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index "$mc_tb(script): You do not have access to view globally."
        return 0
      }
      if {[validchan $channel] && ![matchattr $handle $flags $channel]} {
        putloglev c * "#$handle# (no access) $log_lev_c"
        putdcc $index \
          "$mc_tb(script): You do not have access to view in $channel."
        return 0
      }
      
      putloglev c * "#$handle# $log_lev_c"
      set current_time [clock format [clock seconds] -format "%I:%M%p %A"]
      putdcc $index " --- Current bot time: $current_time"
      putdcc $index "$mc_tb(script) listing for '$channel':"
      set give_space 0
      foreach entry [mc:tb:list list $channel] {
        if {$give_space} {putdcc $index ""}
        
        foreach {
          number channel banmask time days reason added_by time_added
        } $entry break
        
        set days [join [split $days ""]]
        set days [mc:tb:replace -nocase -- $days [list 1 Monday     \
                                                       2 Tuesday    \
                                                       3 Wednesday  \
                                                       4 Thursday   \
                                                       5 Friday     \
                                                       6 Saturday   \
                                                       7 Sunday    ]]

        if {[string match *day* [set time_added [mc:tb:ut2d $time_added]]]} {
          append time_added " ago"
        }

        putdcc $index [format { [%3s] %s}  $number $banmask]
        putdcc $index [format {%7s %-10s: %s} ""      "Channel"    $channel]
        putdcc $index [format {%7s %-10s: %s} ""      "Time"       $time]
        putdcc $index [format {%7s %-10s: %s} ""      "Days"       $days]
        putdcc $index [format {%7s %-10s: %s} ""      "Reason"     $reason]
        putdcc $index [format {%7s %-10s: %s} ""      "Added by"   $added_by]
        putdcc $index [format {%7s %-10s: %s} ""      "Time added" $time_Added]

        if {!$give_space} {set give_space 1}
      }

      return 0
    }
  }
}

bind mode - "% +o" mc:tb:mode:+o
proc mc:tb:mode:+o {nick uhost handle channel mode_change victim} {
  return [mc:tb:errchk mc:tb:mode:+o_ \
    [list $nick $uhost $handle $channel $mode_change $victim]]
}
proc mc:tb:mode:+o_ {nick uhost handle channel mode_change victim} {
  global mc_tb
  if {[isbotnick $victim]} {
    foreach user [chanlist $channel] {
      if {[isbotnick $user]} {continue}
      mc:tb:join $user [getchanhost $user] [nick2hand $user] $channel
    }
  }
}

bind time - * mc:tb:time
proc mc:tb:time {{args ""}} {
  return [mc:tb:errchk mc:tb:time_ [list $args]]
}
proc mc:tb:time_ {{args ""}} {
  global mc_tb
  foreach channel [channels] {
    if {![mc:tb:list can_go $channel]} {continue}
    foreach user [chanlist $channel] {
      if {[isbotnick $user] || ![botisop $channel]} {continue}
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

  if {(($mc_tb(:config:exempt) != "") &&
       [matchattr $handle $mc_tb(:config:exempt) $channel]) ||
      ([channel get $channel dontkickops] &&
       [matchattr $handle o|o $channel])} {
    return 0
  }
  set list [list]
  foreach entry [mc:tb:list list global] {lappend list $entry}
  foreach entry [mc:tb:list list $channel] {lappend list $entry}
  
  foreach entry $list {
    foreach {
      number "" banmask time days reason added_by time_added
    } $entry break
    
    set banmask_l [string tolower $banmask]
    if {![string match $banmask_l [string tolower $nick!$uhost]]} {continue}

    set regex {^(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?}
    append regex {-(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?$}
    if {
      ![regexp -- $regex $time -> start_h start_m start_s stop_h stop_m stop_s]
    } {
      putloglev d * "$mc_tb(script): Invalid time format for number $number."
      continue
    }

    set time_now [clock format [clock seconds] -format "%H %M %w"]
    set time_now [split $time_now]
    set time_now_hour [string trimleft [lindex $time_now 0] 0]
    set time_now_minute [string trimleft [lindex $time_now 1] 0]
    set time_now_day [lindex $time_now 2]
    set time_now_eval [expr ($time_now_hour*60)+$time_now_minute]

    foreach name [list time_now time_now_day time_now_eval start_h start_m \
                       stop_h stop_m] {
      set $name [string trimleft [set $name] 0]
    }

    set start_eval [expr {($start_s == "p")?"12":"1"}]
    set start_eval [expr ($start_h*60)+$start_m+(60*$start_eval)]
    set stop_eval [expr {($stop_s == "p")?"12":"1"}]
    set stop_eval [expr ($stop_h*60)+$stop_m+(60*$stop_eval)]

    if {($time_now_eval < $start_eval) || ($time_now_eval > $stop_eval) ||
        (![string match *$time_now_day* $days])} {continue}

    putserv "MODE $channel +b $banmask"
    putserv "KICK $channel $nick :$reason"
    set temp() "timed ban number $number"
    putloglev o * \
      "$mc_tb(script): Kicking and banning $nick from $channel, $temp()."

    return 1
  }
  return 0
}

bind evnt - save mc:tb:evnt:save
proc mc:tb:evnt:save {type} {
  return [mc:tb:errchk mc:tb:evnt:save_ [list $type]]
}
proc mc:tb:evnt:save_ {type} {mc:tb:list save}

proc mc:tb:list {command {arg ""}} {
  global mc_tb botnet-nick
  set array_name [list :: list]
  if {![info exists mc_tb($array_name)]} {set mc_tb($array_name) ""}
  switch -- $command {
    
    "add" {
      foreach {number channel banmask time days reason handle time_added} $arg \
        break
      set time [string tolower $time]
      if {$time_added == ""} {set time_added [clock seconds]}

      set regex {^(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?}
      append regex {-(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?$}
      if {![regexp -- $regex $time -> a b start_s stop_h stop_m stop_s]} {
        return [list 1 $time]
      }
      set start_h $a
      set start_m $b
      if {(!$start_h) || ($start_h > 12)} {return [list 2 $start_h]}
      if {$start_m > 59} {return [list 3 $start_m]}
      if {(!$stop_h) || ($stop_h > 12)} {return [list 4 $stop_h]}
      if {$stop_m > 59} {return [list 5 $stop_m]}
      set start_s [string index $start_s 0]      
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
      set days_ [list]
      foreach day [split $days ,] {
        if {![regexp -- {[1-7]} $day]} {return [list 6 $day]}
        if {[lsearch -exact $days_ $day] == -1} {lappend days_ $day}
      }
      set days [join [lsort -dictionary $days_] ""]

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
        if {![botisop $channel]} {continue}
        foreach user [chanlist $channel] {
          if {[isbotnick $user]} {continue}
          mc:tb:join $user [getchanhost $user] [nick2hand $user] $channel
        }
      }

      mc:tb:list save quiet
      return [list 0 $return_b]
    }
    
    "delete" {
      set number $arg

      set found 0
      set new_list [list]
      foreach entry [mc:tb:list list all] {
        if {[lindex $entry 0] != $number} {
          lappend new_list $entry
        } else {set found 1}
      }
      if {!$found} {return 0}

      set mc_tb($array_name) $new_list
      set mc_tb($array_name) [lsort -dictionary -index 0 $mc_tb($array_name)]

      mc:tb:list save quiet
      return 1
    }
    
    "can_go" {
      # In: channel

      set channel [string tolower $arg]

      if {![botisop $channel]} {return 0}

      set list [list]
      foreach entry [mc:tb:list list global] {lappend list $entry}
      foreach entry [mc:tb:list list $channel] {lappend list $entry}
  
      foreach entry $list {
        foreach {number "" banmask time days reason added_by time_added} \
          $entry break

        set rgx {^(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?}
        append rgx {-(0?[1-9]|1[0-2]):([0-5]?[0-9])(a|p)m?$}
        if {![regexp -- $rgx $time -> a start_m start_s stop_h stop_m stop_s]} {
          putloglev d * "$mc_tb(script): Invalid time format for number $number"
          continue
        }
        set start_h $a

        set time_now [clock format [clock seconds] -format "%H %M %w"]
        set time_now [split $time_now]
        set time_now_hour [string trimleft [lindex $time_now 0] 0]
        set time_now_minute [string trimleft [lindex $time_now 1] 0]
        set time_now_day [lindex $time_now 2]
        set time_now_eval [expr ($time_now_hour*60)+$time_now_minute]
    
        foreach name [list time_now time_now_day time_now_eval start_h start_m \
                           stop_h stop_m] {
          set $name [string trimleft [set $name] 0]
        }

        set time_now_eval [expr ($time_now_hour*60)+$time_now_minute]
        set start_eval \
          [expr ($start_h*60)+$start_m+(60*[expr {$start_s == "p"?12:1}])]
        set stop_eval \
          [expr ($stop_h*60)+$stop_m+(60*[expr {$stop_s == "p"?12:1}])]

        if {($time_now_eval < $start_eval) || ($time_now_eval > $stop_eval) ||
            (![string match *$time_now_day* $days])} {continue}

        return 1
      }
      return 0
    }
    
    "exists" {
      # In: channel banmask time days
      # List format: <0 next_number>|<current_number>

      foreach {channel banmask time days} $arg break
      foreach item [list channel banmask time days] {
        set $item [string tolower [set $item]]
      }

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
    
    "list" {
      # List format: number channel banmask time days reason added_by time_added
      # In: channel|'all'|'global'

      set channel [string tolower [lindex $arg 0]]

      if {$channel == "all"} {
        return [lsort -dictionary -index 0 $mc_tb($array_name)]
      }

      set return ""
      foreach entry $mc_tb($array_name) {
        if {[lindex $entry 1] == $channel} {lappend return $entry}
      }

      return [lsort -dictionary -index 0 $return]
    }
    
    "getchan" {
      # In: number

      foreach entry $mc_tb($array) {
        if {[lindex $entry 0] == $arg} {return [lindex $entry 1]}
      }
      return ""
    }
    
    "save" {
      if {$arg != "quiet"} {putloglev o * "Writing $mc_tb(script) file..."}

      set io [open $mc_tb(:config:database) w]
      puts $io "#v1:$mc_tb(script):$mc_tb(version):${botnet-nick}:[clock seconds]"
      foreach entry [mc:tb:list list all] {
        puts $io $entry
      }
      close $io
    }
    
    "load" {
      if {$arg != "quiet"} {putloglev o * "Reading $mc_tb(script) file..."}

      set mc_tb($array_name) ""
      if {![file exists $mc_tb(:config:database)]} {
        close [open $mc_tb(:config:database) w]
      }
      set io [open $mc_tb(:config:database) r]
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
      
      if {$arg != "quiet"} {
        putloglev o * \
          "$mc_tb(script): Loaded [llength [mc:tb:list list all]] entries."
      }
    }

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

utimer 1 [list mc:tb:list load]

## SVS insert (post code)
if {![info exists mc_tb(:config:svs:enable)] ||
    ![string match {[01]} $mc_tb(:config:svs:enable)]} {
  set mc_tb(:config:svs:enable) 0
}

bind time - "00 00 *" mc:tb:do_svs
proc mc:tb:do_svs {{args ""}} {
  global mc_tb
  set query $mc_tb(svs:query)
  if {$args == ""} {append query "&log=0"}
  if {[catch {connect $mc_tb(svs:server) $mc_tb(svs:port)} ind]} {
    set temp(1) "SVS problem connecting to $mc_tb(svs:server)"
    set temp(2) "on port $mc_tb(svs:port)"
    putloglev d * "$mc_tb(script): $temp(1) $temp(2):  $ind"
    return 0
  }
  putdcc $ind "GET $mc_tb(svs:get)?$query HTTP/1.0\n"
  putdcc $ind "Host: $mc_tb(svs:server):$mc_tb(svs:port)\n\n"
  control $ind mc:tb:svs_talk
}

proc mc:tb:svs_talk {index text} {
  global mc_tb
  set header [list svs header $index]
  set memory [list svs memory $index]
  if {$text == ""} {
    catch {unset mc_tb($header)}
    catch {unset mc_tb($memory)}
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exist mc_tb($header)]} {
    if {$rfc == "002"} {
      # Done with http header and useless information.
      if {!$mc_tb(:config:svs:enable)} {
        catch {unset mc_tb($header)}
        catch {unset mc_tb($memory)}
        return 1
      }
      set mc_tb($header) 1
    }
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_tb(svs:script)} {
        set temp(1) "wanted $mc_tb(svs:script), got $temp(text:0)"
        putloglev d * "$mc_tb(script): SVS Error: $temp(1)"
        catch {unset mc_tb($header)}
        catch {unset mc_tb($memory)}
        return 1
      }
      return 0
    }

    011 {return 0}
    012 {return 0}
    013 {return 0}
    014 {return 0}
    017 {return 0}

    004 {
      if {[info exists mc_tb($memory)]} {
        set file $mc_tb(info:loc)~new
        set temp(vars) $mc_tb(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_tb($memory)]} {incr i} {
          set line [lindex $mc_tb($memory) $i]
          set regexp {^[; ]*set mc_tb\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set index [lsearch -exact $temp(vars) $item]
              set temp(vars) [lreplace $temp(vars) $index $index]
              puts $io [list set mc_tb($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_tb($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:[; ][; ]*(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_tb($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_tb(info:loc)
        putloglev o * "$mc_tb(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"} error]} {
          file delete -force -- $file~new
          putloglev o * "$mc_tb(script): Auto update failed: $error"
          putloglev o * $::errorInfo
          putloglev o * "$mc_tb(script): Auto update loading previous script."
          uplevel "source $file"
        } else {
          file rename -force -- $file~new $file
          putloglev o * "$mc_tb(script): Auto update test good, reloading."
          uplevel "source $file"
        }
      }

      catch {unset mc_tb($header)}
      catch {unset mc_tb($memory)}
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_tb(script): SVS is being redirected to $temp(cache)."
      utimer 5 [list mc:tb:do_svs_ $temp(host) $temp(port) $temp(get)]
      catch {unset mc_tb($header)}
      catch {unset mc_tb($memory)}
      return 1
    }

    300 {
      lappend mc_tb($memory) $text
      return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) ""}
set index [lsearch -exact $mc_loaded(scripts) mc_tb]
lreplace mc_loaded(scripts) $index $index mc_tb
## ^

putloglev o * "$mc_tb(script) $mc_tb(version) by MC_8 loaded."

#
##

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v1.1 (07.26.02)
#  MC_8 -          - Looked over coding, made many changes ... basic cleanup.
#  MC_8 -          - Upgraded ECS (error catching system).  v3.0 -> v3.1
#  MC_8 -          - Upgraded SVS client.  v3.1 -> v4.0.4
#  MC_8 - Pieter   - Fixed "can't read "time_now_eval": no such variable".
#         beculetz   Bugzilla Bug 202
#
# v1.0 (10.09.02)
#  MC_8 -      - Upgraded SVS Client.  v3.0.1 -> v3.1
#  MC_8 - ting - Fixed '... invalid octal number'.  [Bug: 173]
#  MC_8 - ting - Inital script.
##
