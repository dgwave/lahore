Lahore Web Framework
--------------------

Multi-site and Plugin-enabled Web Framework

- Inspired by Play, Drupal, Shopify Liquid and other excellent open-source projects.

- Written in the intuitive, type-safe and productive [Ceylon](https://github.com/ceylon/) programming language.

Master head is `v0.2` : Compatible with Ceylon 1.1 -- no instructions yet.

Tag `v0.1` : Last tested with Java 1.7, Ceylon 1.0.0 -- on Windows and Linux

### Pre-Alpha software (experimental) Set up:
* Ensure that Java 1.7 or above is installed by typing `java --version` in a command window or shell 
* Download the latest [Ceylon distribution](http://ceylon-lang.org/download/)
 * Unzip it to a folder that will be `CEYLON_HOME`
 * Add the `bin` folder within `CEYLON_HOME` to your PATH environment variable
 * Start a new command-line window (or shell) and type `ceylon --version`. You should see some output
* Choose a clean directory, [download Lahore](https://github.com/dgwave/lahore/archive/master.zip) and unzip it.

### Pre-Alpha (experimental) software - Build:
* Bootstrap the builder: In the folder where you unzipped Lahore, run `ceylon compile --src . build`
* Compile with: `ceylon run build compile`
* Run with `ceylon run com.dgwave.lahore.server.single`
* For more information, see [Wiki pages](https://github.com/dgwave/lahore/wiki).



