Tiny demo of playing different chords using elm-webaudio.

Demo URL ➡️ https://flapperleenie.github.io/elm-progress/index.html

Forked from https://github.com/trotha01/elm-webaudio

Upgraded to elm 0.18.

# Running the programm

To run the examples locally:
```
cd elm-progress
elm-reactor
```

To compile the examples locally:
```
cd elm-progress
elm-make src/Main.elm
```

# To-Dos

* reset play each time to avoid refresh (has to do with stopOscillator in WebAudio.elm)
* change default notes to something sensible
* change model to isOpen.Dropdown
* in general: avoid _ = in exchange for better functions
* play progressions (4-12 bars)
* improve interface: add measure, loop, tempo, ...
* simple vs. advanced mode

# Future Features for Barbershop Arranging

* switch to just tuning
* voice notes to account for voice leading, parallelism, chromatic steps
* randomise chords and voicing
* add more chords to the database
* incorporate database for modulation and substitutions
* incorporate database for common chord progressions, see also
* automated arrangement given chords + melody? see also
