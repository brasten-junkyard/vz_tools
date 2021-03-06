## JUNKYARD ##

This code is possibly unsafe to use (even if it worked; which it probably doesn't).

See https://brasten-junkyard.github.io for details.


# VZTools #

Author: Brasten Lee Sager (brasten@nagilum.com)
Copyright: Copyright 2007, Nagilum LLC

VZTools is a collection of tools and APIs to simplify management of OpenVZ
installations.

VZTools attempts to satisfy three main goals, each successive goal building
on top of the previous one:

    1) Enable access to basic OpenVZ resources via Ruby API, closely
       resembling the actual resources/commands used (vestat, vzlist, etc).

    2) Provide an object model API to OpenVZ resources to greatly simplify
       interactions with OpenVZ from Ruby.  This API in turn uses the lower-
       level API for looking up data and performing requested actions.

    3) Implement command-line tools for OpenVZ similar to those found in
       the commercial Virtuozzo package.  It is NOT a goal of this project
       to exactly duplicate the Virtuozzo tools, but rather to build tools
       that eliminate the need for the Virtuozzo ones and are hopefully
       more powerful.
