# NAME

Sweat - a chatty, distracting, and flexible workout timer.

# SYNOPSIS

Run through a no-frills seven-minute workout:

    sweat

Run through a seven-minute workout, with semi-randomized drills:

    sweat --shuffle

Read in a configuration file and apply its settings:

    sweat --config=/path/to/sweat.config

Force the program to _not_ shuffle, overriding configuration-file settings:

    sweat --no-shuffle

Have the program read news headlines, weather, and tell dumb jokes while
you exercise:

    sweat --entertainment --newsapi-key=MyNewsApiKey12345

See a quick reference of all command-line options:

    sweat --help

# DESCRIPTION

Sweat is a workout timer that helps distract you from the pain of
exercise by chatting incessantly, using your computer's text-to-speech capabilities to read news headlines, crack
strange old-man jokes, talk about the weather, and still manage to call out
workout prompts when necessary.

Sweat is optimized for the so-called Seven-Minute Workout (7MW), which
leads you through twelve 30-second drills, with 10-second rests in
between, focusing on four types of exercise: aerobic, lower-body,
upper-body, and core. While it has sensible and widely accepted
defaults, you can change or expand its list of drills if you really
want, or adjust how many drills each workout entails, or the timing
involved.

Sweat features a friendly pause function, and a shuffle mode that will
randomize the drills you receive within each type while keeping the types themselves in order,
ensuring you get a varied and balanced workout.

Sweat assumes you already know how to perform the drills it calls out,
and trusts you to get through them in whatever way works best for you.
Sweat will never judge you.

Yes, Sweat is a command-line program. Get your butt off the chair once
in a while and onto the floor, fellow hackers. It's good for you.

# USAGE TIPS

Because we have the misfortune to live in the worst timeline, with all
its news spiraling ever worseward, consider _not_ using entertainment
mode when using Sweat to exercise with others. Sweat wants to provide
you with necessary distraction -- not make you feel embarrassed or uncomfortable
among friends, family, or colleagues.

Put on some energetic music instead (sold separately), and feel free to
encourage or distract one another with conversation about literally any
topic other than the news.

# RUNNING SWEAT

## Pausing the workout

With the window running Sweat focused, hit any key (except for control
keys) to pause Sweat; it will click off its timer and stop talking. Hit
a key again to resume the workout.

Pause whenever you need to, or if you need Sweat to shut up for a second
so you can pay attention to something else.

## Ending the workout early

You can bail out of your workout early by just quitting the program in
an ordinary way; Control-C will work on most systems.

Quit whenever you need to, for any reason. Sweat will never judge you.
It will always greet you upon your return with unfeigned gladness.

# CONFIGURATION

## Runtime options

You can set any of these options on the command line, or in a configuration file,
in YAML format. See ["SYNOPSIS"](#synopsis), above, for a few
examples on running sweat with command-line options, or see ["Configuration file"](#configuration-file), below,
for more information on that topic.

Note that you can try running Sweat without any options at all; most settings have
sensible defaults, depending upon your operating system. If sweat requires settings or
other resources that it can't find, it will tell you on startup.

## Configuration file

The configuration file also gives you the opportunity to redefine Sweat's drill-list.

# NOTES

# AUTHOR

Jason McIntosh <jmac@jmac.org>
