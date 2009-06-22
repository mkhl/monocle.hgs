# Monocle Plugin for Google QSB

A [Google Quick Search Box][qsb] plugin to enable access to your [Monocle][]
search engines.

**Download the plugin: <http://github.com/mkhl/monocle.hgs/downloads>**

## Usage

* Hit you QSB keyboard shortcut.
* Type the (partial) name or callword of any search engines you have
  configured in [Monocle][].
* Select the matching object from the result list
* *Tab* into it.
* Type a phrase to search for with that engine.
* Hit *enter* to perform the search.

## Installation

After extracting the plugin, you will find a bundle called `Monocle.hgs`. Copy
this bundle to `~/Library/Application Support/Google/Quick Search
Box/PlugIns`, then restart QSB.

If you built the plugin from source (described below), you will find the
`Monocle.hgs` bundle in your `build` directory.

## Building

Building this plugin requires that you set up two source trees in Xcode. You
will have to have the QuickSearchBox source tree downloaded to your machine.
Instructions on getting the QSB source tree can be found here:
http://code.google.com/p/qsb-mac/source/checkout

To set up the source trees in Xcode:

1. Go to "Xcode>Preferences" and click on the "Source Trees" icon.
2. Click on the "Plus" button on the left hand side of the window.
3. Set the "Setting Name" of your new tree to `QSBBUILDROOT`
4. Set the "Display Name" to `QSBBUILDROOT`
5. Set the path to the debug build directory for QSB. For me the path looks 
   like this `~/src/QuickSearchBox/QSB/build/Debug`. If you use a common build
   directory or some other customized build location, you will have to set it
   here.
6. Click on the "Plus" button again
7. Set the "Setting Name" of your new tree to `QSBSRCROOT`
8. Set the "Display Name" to `QSBSRCROOT`
9. Set the path to the root directory for QSB. For me the path looks 
   like this `~/src/QuickSearchBox`.

The plugin should now build cleanly.

You should only have to add the source trees to Xcode the first time you 
build a QSB plugin.

If you are developing plugins, please join our mailing list:
http://groups.google.com/group/qsb-mac-dev

[qsb]: http://code.google.com/p/qsb-mac/
[monocle]: http://wafflesoftware.net/monocle/
