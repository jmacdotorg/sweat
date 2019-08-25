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
between. These focus on four types of exercise: aerobic, lower-body,
upper-body, and core. While it has sensible and widely accepted
defaults, you can change or expand its list of drills if you really
want, or adjust how many drills each workout entails, or the timing
involved.

Sweat features a friendly pause function, and a shuffle mode that will
randomize the drills you receive within each type while keeping the types themselves in order,
ensuring you get a varied and balanced workout.

Sweat assumes you already know how to perform the drills it calls out (see ["The Seven-Minute Workout"](#the-seven-minute-workout), below)
and trusts you to get through them in whatever way works best for you.
Sweat will never judge you.

Yes, Sweat is a command-line program. Get your butt off the chair once
in a while and onto the floor, fellow hackers. It's good for you.

## How Sweat is different from other timers

Sweat's major features that most other 7MW timers don't have:

### A speech-centered UI

Sweat guides you through voice alone (with a simple text transcription in its terminal window).

### Chatty entertainment while you struggle

Sweat will (unless you ask it not to) click through a randomly chosen thread of related Wikipedia articles while you work out and read aloud what it finds.
The workout takes priority, so this intentionally distracting chatter will not make you miss any exercise cues.

With a little extra configuration, you can have Sweat instead read you current news headlines from a variety of sources.

Sweat will also tell you the local weather during certain drills, and end by reading aloud the output of the \`fortune\` program (if available).

### Optional drill-shuffling

For variety's sake, you can shuffle the drills out of their standard order. While you still get three rounds of aerobic, lower-body, upper-body, and core drills in that order, Sweat will randomize the order of the three drills within each category.

### Pause between side-switching

Halfway through the side-plank drill, Sweat gives you a few seconds to adjust yourself.
(For some reason, few if any other timers seems to bother with this.)

### No-chair and no-jumping modes

A no-chair mode that substitutes other drills when you find yourself in a space (e.g. a hotel room) with no suitably stable chair to exercise with.

A no-jumping mode is also available when you want to avoid stomping around on your downstairs neighbor's ceiling.

## The Seven-Minute Workout

If you're not already familiar with 7MW and its twelve drills, [this New York Times article may serve as an excellent introduction](https://well.blogs.nytimes.com/2013/05/09/the-scientific-7-minute-workout/).

As that article suggests, oodles of apps and websites exist for all your mobile and desktop devices
to help guide you through 7MW. Some of them will work better than Sweat at making you familiar
with the exercises involved; you may find it helpful to check them out first.

[You may also wish to read thoughts by Sweat's author about 7MW](https://fogknife.com/2015-01-11-seven-minute-workout.html).

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

# OPTIONS AND CONFIGURATION

## Basic options

You can set any of these options on the command line, or in a configuration file. See ["SYNOPSIS"](#synopsis), above, for a few
examples on running sweat with command-line options, or see ["Configuration file"](#configuration-file), below,
for more information on that topic.

**For boolean options** (such as `shuffle`), simply name them on the command line to invoke
them: `--shuffle`, for example. To negate on the command like, precede with "no-", e.g.
`--no-shuffle`. To set them in a configuration file, set them to 0 or 1 with YAML
syntax: `shuffle: 1`.

**For other options**, set them on the command line with an equals sign
(--newsapi\_key=MySecretKey), or in a config file with YAML syntax
(`newsapi_key: MySecretKey`).

Note that you can try running Sweat without any options at all; most settings have
sensible defaults, depending upon your operating system. If sweat requires settings or
other resources that it can't find, it will tell you on startup.

### shuffle

**Boolean.** Shuffle the drills before presenting them. It will still present three
sets of four drills in the same style-order (aerobic, then lower-body,
then upper-body, and finally core).

Default: 0 (No shuffling)

### entertainment

**Boolean.** Allow Sweat to entertain you during the workout by reading articles fetched over
the internet, the current weather, and other stuff.

See ["Entertainment options"](#entertainment-options) to fine-tune this behavior.

Default: 1

### chair

**Boolean.** Indicates the availability of a chair, for certain drills.

If false, then drills requiring a chair will
replace themselves with a random drill of the same style. (For example, a chairsome
aerobic drill will get replaced with another, less chairish aerobic drill.)

Default: 1

### jumping

**Boolean.** Indicates the tolerability of jumping, for certain drills.

If false, then drills involving jumping or stomping will replace
themselves with a random drill of the same style.

### speaker-program

A valid command-line invocation of your computer's text-to-speech program, including any
command-line arguments you may wish to include. It must take an arbitrary string of text
as its main argument. Sweat will invoke this program every time it wishes to say something.

Default: On Mac, it will default to using "say", a program that comes with the OS. On
other systems, it will try "espeak", a free and open-source program that you may
need to install first. You can find espeak in various package managers, or at
[http://espeak.sourceforge.net](http://espeak.sourceforge.net).

## Entertainment options

These options come into play only while running Sweat in entertainment mode
(see ["entertainment"](#entertainment), above).

### newsapi-key

An application key for NewsAPI. If provided with a valid key, then Sweat will
fetch, read, and display top news headlines from a variety of sources during
your workout (unless run in `no-news` mode).

You can fetch a free key for personal use at [https://newsapi.org](https://newsapi.org).

If _not_ set, then Sweat will read and display Wikipedia articles instead.

Default: none

### country

The two-letter code for the country that NewsAPI will fetch its headlines from.

Default: us

### url-program

A valid command-line invocation (including any desired options) for a program that opens a URL (provided as a main
argument) in a browser.

Default: On Mac, it will default to "open", a program that comes with the OS.
On other it will try "xdg-open", a free and open-source program that you may
need to install first. You can find xdg-open as part of "xdg-utils" in various package managers, or at
[https://freedesktop.org/wiki/Software/xdg-utils/](https://freedesktop.org/wiki/Software/xdg-utils/).

### fortune-program

A valid command-line invocation (including any desired options) for a program that will say something witty (according to a typical Unix system administrator in 1988).
When in entertainment mode, Sweat will invoke this at the end of every workout,
reading the results out loud.

## Command-line-only options

These options work only on the command line (and have no effect in a config file).

### config

Full path to a Sweat configuration file, in [YAML](https://metacpan.org/pod/YAML) format.

Default: `.sweat`, in your home directory. (i.e. `$HOME/.sweat`)

### no-news

Forces Sweat to use Wikipedia articles as its main source of workout chatter,
even if a valid NewsAPI key has been provided (via ["newsapi\_key"](#newsapi_key)).

### version

Prints version and authorship information about Sweat, then exits.

### help

Prints a quick reference to Sweat's command-line options, then exits.

Default: fortune

## Configuration file

You can optionally provide Sweat with a configuration file in YAML format. Sweat
will load this on startup, and apply all its settings _before_ applying any settings
provided on the command line (thus letting you override config-file settings that way).

You can provide a path to such a file via the ["config"](#config) command-line option. If
you don't, Sweat will look for a config file at `$HOME/.sweat`, and if it doesn't
find one there either it will continue without a config file.

If the config file exists but Sweat's YAML parser can't work with it, Sweat will
complain and then exit.

In the config file, you can set any of the options listed under ["Basic options"](#basic-options)
or ["Entertainment options"](#entertainment-options), using YAML syntax.

The configuration file also gives you the opportunity to redefine Sweat's drill-list.
You can accomplish this by defining a `groups` attribute, which contains several
groups of related drills.

Please allow me to explain further by simply showing the definition for Sweat's
default drills, which demonstrate all the special attributes meaningful to
individual drill definitions.

    groups:
     - name: aerobic
       drills:
         - name: jumping jacks
           requires_jumping: 1
         - name: high knees
           requires_jumping: 1
         - name: step-ups
           requires_a_chair: 1
     - name: lower-body
       drills:
         - name: wall sit
         - name: squats
         - name: knee lunges
     - name: upper-body
       drills:
         - name: push-ups
         - name: tricep dips
           requires_a_chair: 1
         - name: rotational push-ups
     - name: core
       drills:
         - name: abdominal crunches
         - name: plank
         - name: side plank
           requires_side_switching: 1

Please note that the `groups` attribute is not additive; if you define it at all,
then you must define _all_ the drills and drill-groups that Sweat will use.

# NOTES

The default drills specify "knee lunges" and "abdominal crunches" because the words "lunges"
and "crunches" sound too similar, without further context.

# AUTHOR

Jason McIntosh <jmac@jmac.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Jason McIntosh.

This is free software, licensed under:

    The MIT (X11) License

# A PERSONAL REQUEST

My ability to share and maintain free, open-source software like this
depends upon my living in a society that allows me the free time and
personal liberty to create work benefiting people other than just myself
or my immediate family. I recognize that I got a head start on this due
to an accident of birth, and I strive to convert some of my unclaimed
time and attention into work that, I hope, gives back to society in some
small way.

Worryingly, I find myself today living in a country experiencing a
profound and unwelcome political upheaval, with its already flawed
democracy under grave threat from powerful authoritarian elements. These
powers wish to undermine this society, remolding it according to their
deeply cynical and strictly zero-sum philosophies, where nobody can gain
without someone else losing.

Free and open-source software has no place in such a world. As such,
these autocrats' further ascension would have a deleterious effect on my
ability to continue working for the public good.

Therefore, if you would like to financially support my work, I would ask
you to consider a donation to one of the following causes. It would mean
a lot to me if you did. (You can tell me about it if you'd like to, but
you don't have to.)

- [The American Civil Liberties Union](https://aclu.org)
- [The Democratic National Committee](https://democrats.org)
- [Earthjustice](https://earthjustice.org)

If these words do move you to make a donation of at least $10 to any nonprofit making the world better, and you let me
know about it, I will mail you sticker as a token of gratitude. See
[this article on my blog](https://fogknife.com/2019-08-03-how-to-support-fogknife.html) for
more information.
