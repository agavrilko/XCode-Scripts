## StringsConsistency.sh

Script allows to check whether all localization files contain consistent lists of localized strings.

It takes two arguments:

- Name of the main localization folder (en.lproj for example)
- Name of the localization files to check (Localizable.strings for example)

Script generates warning for every file that have missed or extra tokens in its list.

### Output example
For example, if we have 2 localization files with following content:

**en**

![en.lproj/Localization.strings](/.md/images/example-en.png)

**ru**

![ru.lproj/Localization.strings](/.md/images/example-ru.png)

And use *en.lproj* as main, script will generate warning for localization file from 'ru.lproj':

![warning](/.md/images/example-warning.png)

### How to use
![usage-example](/.md/images/how-to-use.png)
