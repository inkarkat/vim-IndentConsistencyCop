INDENT CONSISTENCY COP
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

In order to achieve consistent indentation, you need to agree on the
indentation width (e.g. 2, 4 or 8 spaces), and the indentation method (only
tabs, only spaces, or a mix of tabs and spaces that minimizes the number of
spaces and is called 'softtabstop' in Vim). Unfortunately, different people
use different editors and cannot agree on "the right" width and method.
Consistency is important, though, to make the text look the same in different
editors and on printouts. If any editor inadvertently converts tabs and
spaces, version control and diff'ing will be much harder to do.

The IndentConsistencyCop examines the indent of the buffer and analyzes the
used indent widths and methods. If there are conflicting ones or if bad
combinations of tabs and spaces are found, it alerts you and offers help in
locating the offenders - just like a friendly policeman:

    :IndentConsistencyCop

    Found inconsistent indentation in this buffer; generated from these
    conflicting settings:
    - tabstop (1838 of 3711 lines) <- buffer setting
    - 4 spaces (33 of 3711 lines)
    - bad mix of spaces and tabs (4 of 3711 lines)
        [I]gnore, (J)ust change buffer settings..., (H)ighlight wrong
        indents...:  h
    What kind of inconsistent indents do you want to highlight?
        Not [b]uffer settings (sts4), Not best (g)uess (tab), Not (c)hosen
        setting..., (I)llegal indents only: g
    Marked 180 incorrect lines.

If the buffer contents are okay, the IndentConsistencyCop can evaluate whether
Vim's buffer settings are compatible with the indent used in the buffer. The
friendly cop offers to correct your buffer settings if you run the risk of
screwing up the indent consistency with your wrong buffer settings:

    :IndentConsistencyCop

    The buffer's indent settings are inconsistent with the used indent '8
    spaces'; these settings must be changed:
    - expandtab from 0 to 1
    How do you want to deal with the inconsistency?
        [I]gnore, (C)hange: c
    The buffer settings have been changed: tabstop=8 softtabstop=0 shiftwidth=8
    expandtab

The IndentConsistencyCop is only concerned with the amount of whitespace from
column 1 to the first visible character; it does not check the alignment of
tables, equals signs in variable assignments, etc. Neither does it know any
specifics about programming languages, or your personal preferred indentation
style.

### SEE ALSO

- IndentConsistencyCopAutoCmds ([vimscript #1691](http://www.vim.org/scripts/script.php?script_id=1691)) complements this plugin. It
  automatically triggers the IndentConsistencyCop for certain filetypes when
  loading the buffer and optionally also on each write

### RELATED WORKS

- Indent Finder ([vimscript #513](http://www.vim.org/scripts/script.php?script_id=513)) is a Python script and Vim plugin that scans
  any loaded buffer and configures the appropriate indent settings
- yaifa.vim ([vimscript #3096](http://www.vim.org/scripts/script.php?script_id=3096)) is a port to vimscript of the above
- detectindent.vim (https://github.com/ciaranm/detectindent) by Ciaran
  McCreesh tries to auto-detect the indentation settings
- GuessIndent ([vimscript #4251](http://www.vim.org/scripts/script.php?script_id=4251)) is based on detectindent.vim
- indentdetect.vim
  (https://github.com/ervandew/vimfiles/blob/master/vim/plugin/indentdetect.vim)
  by Eric Van Dewoestine performs a simple detection and can set defaults
  based on the filespec
- matchindent.vim ([vimscript #4066](http://www.vim.org/scripts/script.php?script_id=4066)) detects tabs, 2 and 4-space indents and
  adapts the indent settings accordingly
- sleuth.vim ([vimscript #4375](http://www.vim.org/scripts/script.php?script_id=4375)) by Tim Pope automatically adjusts 'shiftwidth'
  and 'tabstop' heuristically (via a simplistic sampling that does not check
  for bad or inconsistent indents) or by looking at other files of the same
  type
- filestyle ([vimscript #5065](http://www.vim.org/scripts/script.php?script_id=5065)) highlights tabs when 'expandtab' is set,
  trailing spaces, and lines longer than 'textwidth', but doesn't actually
  check conformance to indent
- ShowSpaces ([vimscript #5148](http://www.vim.org/scripts/script.php?script_id=5148)) highlights spaces inside indentation, per
  buffer / filetype.
- Indent Detector ([vimscript #5195](http://www.vim.org/scripts/script.php?script_id=5195)) run when a file is opened or written, has
  warnings about mixed tab / space indent, and can adapt Vim's corresponding
  options automatically.

USAGE
------------------------------------------------------------------------------

    Start the examination of the current buffer or range via:
        :[range]IndentConsistencyCop [{setting}]
    The optional {setting} specifies the assumed correct indent setting for the
    buffer / range (if omitted the cop can later be told), as combination of
    either tab, spc, or sts with a number between 1-8, e.g. "sts4" for a
    4-character soft tabstop indent.
    The triggering can be done automatically for configurable filetypes with the
    autocmds defined in IndentConsistencyCopAutoCmds.vim ([vimscript #1691](http://www.vim.org/scripts/script.php?script_id=1691)).

    If you chose to highlight incorrect indents, either re-execute the
    IndentConsistencyCop to update the highlighting, or execute
        :IndentConsistencyCopOff
    to remove the highlightings. Entries in the quickfix and location lists will
    be kept.

    If you just want to check a read-only file, or do not intend to modify the
    file, you don't care if Vim's buffer settings are compatible with the used
    indent. In this case, you can use
        :[range]IndentRangeConsistencyCop [{setting}]
    instead of :IndentConsistencyCop.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-IndentConsistencyCop
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim IndentConsistencyCop*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.039 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

You can select method(s) of highlighting incorrect lines via
g:indentconsistencycop\_highlighting; the default fills the search pattern,
jumps to the first error, sets 'list', uses the 'Error' highlighting and folds
away the correct lines.
The variable defines the highlighting methods of incorrect lines, when this is
requested by the user. Multiple methods can be combined by concatenating the
values. The changes done for highlighting are undone when highlighting is
removed via :IndentConsistencyCopOff.
    s - Fill search pattern with all incorrect lines, so that you navigate
        through all incorrect lines with n/N.
    g - Jump to the first error.
    l - As a visualization aid, execute ':setlocal list' to see difference
        between tabs and spaces.
    m - Use error highlighting to highlight the wrong indent via the
        'IndentConsistencyCop' highlight group. This is especially useful if
        you don't use the search pattern in combination with 'set hlsearch'
        to locate the incorrect lines.
        You can customize this by defining / linking the
        'IndentConsistencyCop' highlight group before this script is
        sourced: >
            highlight link IndentConsistencyCop Error
    f:{n} (n = 0..9)
      - Fold correct lines with a context of {n} lines (like
        in Vim diff mode).
    q - Populate quickfix list with all incorrect lines. With uppercase Q
        appends to an existing list.
    w - Populate location list with all incorrect lines. With uppercase W
        appends to an existing list.

    let g:indentconsistencycop_highlighting = 'sglmf:3'

You can offer alternative method(s) of highlighting incorrect lines; the
default adds lines to the quickfix list:

    let g:IndentConsistencyCop_AltHighlighting =
    \   {'methods': 'Q', 'menu': 'Add wrong indents to &quickfix...'}

The configuration is a Dict with a "methods" entry (cp.
g:indentconsistencycop\_highlighting) and a "menu" entry. If empty, no
alternative method will be presented.

Some comment styles use additional whitespace characters inside the comment
block to neatly left-align the comment block, e.g. this is often used in Java
and C/C++ programs:

    /* This is a comment that spans multiple
     * lines; neatly left-aligned with asterisks.
     */

The IndentConsistencyCop would be confused by these special indents, so the
non-indent pattern defined in g:indentconsistencycop\_non\_indent\_pattern
removes these additional whitespaces from the indent when evaluating lines.

    let g:indentconsistencycop_non_indent_pattern = ' \*\%([*/ \t]\|$\)'

(You can also override / set this for certain files with a buffer-local var.)
The pattern could also match in non-comment lines; to avoid that, the cop can
additionally check for a syntax match at the comment position, by supplying a
regular expression for the syntax item name, and optionally another one for a
syntax item name that stops looking further down the syntax stack:

    let g:indentconsistencycop_non_indent_pattern = [' \*\%([*/ \t]\|$\)',
    \ '^Comment$', 'FoldMarker$']

These are only considered when :syntax on.

You may never want certain indent settings in your files. As an indent
multiplier of 1 more often is the result of a mess of different indents than
an explicit choice, the default forbids 'spc1' and 'sts1' from being accepted
as consistent indentation:

    let g:IndentConsistencyCop_UnacceptableIndentSettings = ['spc1', 'sts1']

Assign an empty List or String to accept any indent setting. As an alternative
to the List of unacceptable indent settings, this configuration can also take
a regular expression pattern:

    let g:IndentConsistencyCop_UnacceptableIndentSettings = '^sts'

Some comment styles use irregularly indented blocks, for example aligment to a
start of a keyword or construct in the previous line, without regard to
whether that aligns with the indent width. To avoid annoying false positives
on those lines, you can implement custom function(s) that detect these, so
that they will be excluded from the cop's checking. Define a List of Funcrefs:

    let g:IndentConsistencyCop_line_filters =
    \   [function('MyBlockFilter'), function('MyBoilerplateFilter')]

The function must take two startLnum, endLnum arguments and return a
Dictionary whose keys represent the filtered out line numbers. The cop ignores
the union of all returned Sets.

In case of really irregular lines where the removal of some whitespace per
g:indentconsistencycop\_non\_indent\_pattern isn't possible, the lines can be
ignored altogether. Lines can be selected by a List of patterns, optionally
limited to certain syntax item names (tested after the matched text),
optionally with another one for a syntax item name that stops looking further
down the syntax stack:

    let g:IndentConsistencyCop_IgnorePatterns = [
    \   '^\s\+####D',
    \   ['^\s\+', 'podVerbatimLine']
    \]

(This is implemented as a default g:IndentConsistencyCop\_line\_filters.)

By default, the cop sets 'copyindent' and 'preserveindent' if the buffer's
indent is inconsistent and this is ignored by the user, as these options
typically make Vim respect the original indent. This is undone automatically
if the buffer becomes consistent or the cop is turned off via
:IndentConsistencyCopOff. To disable this feature, set

    let g:IndentConsistencyCop_IsCopyAndPreserveIndent = 0

(This is implemented as a default IndentConsistencyCop-event.)

By default, the cop also checks for bad whitespace combinations (i.e. space
character(s) followed by one or more tabs) everywhere inside the buffer, not
just in indent. To turn this off and just alert to these bad mixes when they
occur at the beginning of the line:

    let g:IndentConsistencyCop_IsFindBadMixEverywhere = 0

The default block alignment g:IndentConsistencyCop\_line\_filters, can be
tuned with regards to what it considers a block via:

    let g:IndentConsistencyCop_BlockAlignmentPattern = '\<'

The default handles alignment to previous keywords, brackets, quotes, and
@Annotation, $var.

INTEGRATION
------------------------------------------------------------------------------

The :IndentConsistencyCop and :IndentRangeConsistencyCop commands fill a
buffer-scoped dictionary with the results of the check. These results can be
consumed by other Vim integrations (e.g. for a custom 'statusline').

    b:indentconsistencycop_result.maxIndent
Maximum indent (in columns) found in the entire buffer. (Not reduced by range
checks.)

    b:indentconsistencycop_result.minIndent
Minimum indent (in columns, not counting lines that do not start with
whitespace at all) found in the entire buffer. (Not increased by range
checks.)

    b:indentconsistencycop_result.indentSetting
String representing the actual indent settings. Consistent indent settings are
represented by 'tabN', 'spcN', 'stsN' (where N is the indent multiplier) or
'none' (meaning no indent found in buffer). Completely inconsistent indent
settings are shown as 'XXX'; a setting which is almost consistent, with only
some bad mix of spaces and tabs, is represented by 'BADtabN', 'BADspcN' or
'BADstsN'.

    b:indentconsistencycop_result.isConsistent
Flag whether the indent in the entire buffer is consistent. (Not set by range
checks.)

    b:indentconsistencycop_result.isDefinite
Flag whether there has been enough indent to make a definite judgement about
the buffer indent settings. (Not set by range checks.)

    b:indentconsistencycop_result.acknowledgedByUserSetting
Indent setting that the user has explicitly acknowledged in its interaction
with the cop (by answering "Wrong" or "Change" in one of the dialogs).

    b:indentconsistencycop_result.isDefiniteOrAcknowledgedByUser
Combination of the above two: Flag whether there either has been enough indent
to make a definite judgement about the buffer indent settings, or whether the
user has explicitly acknowledged the current indent settings in its
interaction with the cop (by answering "Wrong" or "Change" in one of the
dialogs).

    b:indentconsistencycop_result.bufferSettings
String representing the buffer settings. One of 'tabN', 'spcN', 'stsN' (where
N is the indent multiplier), or '???' (meaning inconsistent buffer indent
settings).

    b:indentconsistencycop_result.isBufferSettingsConsistent
Flag whether the buffer indent settings (tabstop, softtabstop, shiftwidth,
expandtab) are consistent with each other.

    b:indentconsistencycop_result.isConsistentWithBufferSettings
Flag whether the indent in the entire buffer is consistent with the buffer
indent settings. (Not set by range checks; :IndentRangeConsistencyCop leaves
this flag unchanged.)

    b:indentconsistencycop_result.isIgnore
Flag whether the user chose to ignore the inconsistent results. This can be
used by integrations (like IndentConsistencyCopAutoCmds) to cease scheduling
of further cop runs in this buffer.

    b:indentconsistencycop_result.isOff
Flag whether the cop has been (at least temporarily) disabled via
:IndentConsistencyCopOff.

The user queries can be extended with additional menu entries, defined in a
Dictionary:

    let g:IndentConsistencyCop_MenuExtensions = {
    \   'Dummy': {
    \       'priority': 100,
    \       'choice':   'Dumm&y',
    \       'Action':   function('DummyAction')
    \   },
    \   [...]
    \}

With the optional "choice" attribute, you can define an accelerator key via &amp;;
the rest of the text must be identical to the key!
The optional "priority" attribute determines the order of the extension
entries; they will always come after the plugin's core entries, though.
The mandatory "Action" attribute is a Funcref to a function that is invoked
without arguments if the menu entry is chosen.

The plugin emits a User event "IndentConsistencyCop" after each run.
Integrations can check the b:indentconsistencycop\_result dictionary to react
differently to various conditions. For example:

    augroup IndentConsistencyCopCustomization
        autocmd!
        autocmd User IndentConsistencyCop unsilent echomsg 'The cop is'
        \   b:indentconsistencycop_result.isOff ? 'off' : 'on'
    augroup END

The following turns the buffer read-only if it is inconsistent:

        autocmd User IndentConsistencyCop let &l:readonly =
        \   ! b:indentconsistencycop_result.isConsistent &&
        \   ! b:indentconsistencycop_result.isOff

LIMITATIONS
------------------------------------------------------------------------------

- Highlighting of inconsistent and bad indents is static; i.e. when modifying
  the buffer / inserting or deleting lines, the highlighting will be wrong /
  out of place. You need to re-run the IndentConsistencyCop to fix the
  highlighting.

### ASSUMPTIONS

- When using 'softtabstop', 'tabstop' remains at the standard value of 8. Any
  other value would sort of undermine the idea of 'softtabstop', anyway.
- The indentation value lies in the range of 1-8 spaces or is 1 tab.
- When 'smarttab' is set (global setting), 'tabstop' and 'softtabstop' become
  irrelevant to front-of-the-line indenting; only 'shiftwidth' counts.
- There are two possibilities to model 'expandtab': Either set the indent via
  'tabstop', or keep 'tabstop=8' and set the indent via 'softtabstop'. We use
  the following guideline:
  If tabstop is kept at the standard 8, we prefer changing the indent via
  softtabstop.
  If tabstop is non-standard, anyway, we rather modify tabstop than turning on
  softtabstop.

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-IndentConsistencyCop/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 3.00    20-Feb-2020
- Add b:indentconsistencycop\_result.acknowledgedByUserSetting
- ENH: Allow extension of the plugin's user queries with additional menu
  entries. This is used by IndentConsistencyCopAutoCmds.vim to implement
  blacklisting of certain files so that they are never checked again.
- Add g:IndentConsistencyCop\_UnacceptableIndentSettings and by default forbid
  indents with multiplier 1 (i.e. 'spc1' and 'sts1') from being accepted as
  consistent indentation.
- ENH: g:indentconsistencycop\_non\_indent\_pattern now also enforces a comment
  syntax item (if :syntax on) for applying the special indent pattern, to
  avoid false positives in non-comment lines that just look like they're
  starting with a comment prefix.
- Add g:IndentConsistencyCop\_IgnorePatterns to completely ignore certain lines
  that match a pattern (and optionally have a certain syntax item name),
  implemented as a default g:IndentConsistencyCop\_line\_filters.
- Emit "IndentConsistencyCop" User event after each cop command, so that
  customizations can react to the results.
- Set 'copyindent' and 'preserveindent' when the buffer is inconsistent and
  this is ignored (configurable via
  g:IndentConsistencyCop\_IsCopyAndPreserveIndent).
- ENH: Allow passing correct indent setting as an :Indent[Range]ConsistencyCop
  argument. (Overriding of a wrongly found indent setting is already offered
  in the cop's dialog.)
- Alert to bad "tab after space" whitespace combinations everywhere, not just
  in indent. Can be configured (turned off) via
  g:IndentConsistencyCop\_IsFindBadMixEverywhere.
- ENH: Allow population of quickfix / location list via
  g:indentconsistencycop\_highlighting values q/Q/w/W.
- Offer alternative highlighting methods in menu via
  g:IndentConsistencyCop\_AltHighlighting, by default adding to the quickfix
  list.
- Allow to tweak IndentConsistencyCop#BlockAlignment#Filter() via
  g:IndentConsistencyCop\_BlockAlignmentPattern.
- Also support @Annotation, $var as starts of blocks.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.039!__

##### 2.00    23-Dec-2017
- Minor: Replace explicit regexp engine workaround with ingo/compat/regexp.vim.
- When choosing "Highlight wrong indents..." followed by "Not best guess" or
  "Not chosen setting", also adapt the buffer settings to that indent setting,
  as the user has indicated that this is the right one.
- ENH: Add "Just change buffer settings" alternative for "Highlight wrong
  indents..." search that only adapts the buffer settings, but does not (in
  fact clears any) highlight. Often, I must not fix existing wrong
  indentation, but still would like to adapt my buffer settings to cause no
  addition harm to the file's indent.
- ENH: Also query the value (multiplier) of 'tabstop' when querying for the
  indent setting. Though this doesn't affect the consistent / inconsistent
  verdict, it's often an important aspect of a correct visualization.
- Support buffer-local b:indentconsistencycop\_non\_indent\_pattern
  configuration, too.
- Introduce additional
  b:indentconsistencycop\_result.isDefiniteOrAcknowledgedByUser reporting flag.
- Offer "Wrong, use buffer settings" in addition to the existing "Wrong,
  choose correct setting" if the buffer settings are consistent.
- When choosing Ignore on reported inconsistencies in the indent, turn off
  any previous highlighting by the cop (like :IndentConsistencyCopOff).
- Restore last search pattern from history when turning off the cop.
- When there are bad mixes of spaces and tabstop, the individual character
  widths can't be simply accumulated; need to use strdisplaywidth() to arrive
  at the correct indent width.
- FIX: :.IndentConsistencyCop on a closed fold only considers the current
  line, not all lines inside the fold. Need to use ingo#range#NetStart/End().
- ENH: Add g:IndentConsistencyCop\_line\_filters configuration to exclude
  certain, irregular lines from checking. This is a more powerful variant of
  g:indentconsistencycop\_non\_indent\_pattern. Use
  IndentConsistencyCop#Filter#BlockAlignment() by default, which handles
  alignment to previous keywords, brackets, and quotes.
- When the best guess is equal to the buffer indent, already indicate that in
  the Ignore action choice. This wasn't made clear enough by the full
  description, and users are tempted to choose |Just change buffer settings|,
  where then the buffer setting isn't available, and the setting would have to
  be tediously re-chosen.
- CHG: Default to Change instead of Ignore when just the buffer settings
  are wrong, and the assessment is solid. This is the most common (and
  sensible) choice. If there's not enough indent for that, don't default to
  anything.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.024!__

##### 1.45    12-Dec-2014
- Minor: Highlight action checks are dependent on 'iskeyword' setting, and
  could cause script errors.
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

__You need to separately
  install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.019 (or higher)!__

##### 1.44    11-Jan-2014
- BUG: The version 1.43 workaround for the Vim 7.4 new regexp engine was
  ineffective, because the \\%#=1 atom needs to be prepended to the entire
  regular expression, but that's not possible with the configuration value
  alone. (Also, the workaround mistakenly specified auto-select (0) instead of
  old engine (1).) Move the workaround to s:GetBeginningWhitespace() instead.
- ENH: Close all consistent parts of the buffer when highlighting the
  inconsistencies via folding, and restore the original 'foldlevel' setting
  (and therefore the global fold state set by zM / zR) on
  :IndentConsistencyCopOff. Thanks to Marcelo Montu for the idea.
- ENH: Enable folding to highlight the inconsistencies when it was previously
  :set nofoldenable'd.

##### 1.43    19-Dec-2013
- Minor: Make matchstr() robust against 'ignorecase'.
- Improve g:indentconsistencycop\_non\_indent\_pattern to also handle empty
  comment lines with a sole ' \*' prefix. Thanks to Marcelo Montu for reporting
  this.

##### 1.42    10-Dec-2012
- When a perfect or authoritative rating didn't pass the majority rule, try to
turn around the verdict by checking consistency with buffer settings, as is
done for small indents only. For example, this avoids a wrong verdict of
inconsistent spc8 when there are more spc8 than spc4. Thanks to Marcelo Montu
for reporting this issue.

##### 1.41    07-Dec-2012
- Change the behavior of :IndentRangeConsistencyCop to consider the buffer
settings to turn around the verdict of "inconsistent indent" (but still not
report inconsistent buffer settings alone). Otherwise, together with the
IndentConsistencyCopAutoCmds triggers, it can happen that on opening (i.e.
:IndentConsistencyCop), the file is judged okay (considering the buffer
settings), but on writing the buffer (:IndentRangeConsistencyCop), a potential
inconsistency due to too small indent is reported. Thanks to Marcelo Montu for
reporting this issue.

##### 1.40    11-Oct-2012
- The cop can often do a solid assessment when the maximum indent is 8.
  Only when there are no smaller indents, a higher indent is needed to
  unequivocally recognize soft tabstops.
- ENH: Better handle integer overflow when rating and normalizing: Limit to
  MAX\_INT instead of carrying on with negative ratings, or just use Float
  values when Vim has support for it.
- When we have only a few, widely indented lines, there may be more than one
  way to interpret them as a perfect setting. Choose one over the other via
  some simple heuristics instead of the previous assertion error.
- FIX: Fall back to the old :2match when matchadd() is not available.

##### 1.31    03-Apr-2012
- Use matchadd() instead of :2match to avoid clashes with user highlightings
  (or other plugins like html\_matchtag.vim).
- ENH: Clear highlighting when another buffer is loaded into the window to
  avoid that the highlightings persist in a now wrong context.

##### 1.30    23-Nov-2011
- ENH: Avoid the spurious "potential inconsistency with buffer settings" warning
when there are only small consistent indents detected as space-indents, but
the equivalent softtabstop-indent is consistent with the buffer settings. As
many files only have small indents, this warning popped up regularly and has
been the most annoying for me, also because to rectify it, one has to answer
three questions: "[W]rong", "[s]ofttabstop", [N]).

##### 1.21    31-Dec-2010
- Added b:indentconsistencycop\_result.isIgnore to allow the
  IndentConsistencyCopAutoCmds integration to suspend further invocations of
  the cop in the buffer.
- BUG: :IndentRangeConsistencyCop didn't report inconsistencies at all because
  of a bad conditional statement introduced in 1.20.014.
- Using separate autoload script to help speed up Vim startup.
- Added separate help file and packaging the plugin as a vimball.

##### 1.20    22-Jul-2008
- BF: Undefined variable l:isEntireBuffer in IndentBufferConsistencyCop().

##### 1.20    21-Jul-2008
- ENH: Added b:indentconsistencycop\_result buffer-scoped dictionary containing
  the results of the check, which can be used by other integrations. Also
  check consistency of buffer settings if the buffer/range does not contain
  indented text. Inconsistent indent settings can then be corrected with a
  queried setting.
- BF: Clear previous highlighting if buffer/range now does not contain
  indented text.

##### 1.10    23-Jun-2008
- Minor change: Added -bar to all commands that do not take any arguments, so
that these can be chained together.

##### 1.10    28-Feb-2008
- Improved the algorithm so that 'softtabstop' is recognized even when a file
only has small indents with either (up to 7) spaces or tabs, but no tab +
space combination.

##### 1.00    08-Nov-2007
- BF: In an inconsistent and large buffer/range that has only one or a few
  small inconsistencies and one dominant (i.e. 99%) setting, the text "Some
  minor / inconclusive potential settings have been omitted." is not printed.
- ENH: Print "noexpandtab/expandtab" instead of " expandtab to 0/1", as the
  user would :setlocal the setting.

##### 1.00    04-Jun-2007
- ENH: Improved detection accuracy for soft tabstops when the maximum indent is
too small for a solid assessment. When the maximum indent of the buffer is not
enough to be sure of the indent settings (i.e. differentiating between soft
tabstops and spaces), an inconsistent indent was reported, even though it is
much more likely that the indent is consistent with "soft tabstop n", but that
wasn't recognized because of the small indents used in the file. If allowed,
the cop now examines the buffer settings to possibly turn around the verdict
of "inconsistent indent".

##### 1.00    02-Apr-2007
- Allowing user to override wrongly found consistent setting (e.g. 'sts1'
instead of 'tab') by choosing 'Wrong, choose correct setting...' in the
IndentBufferConsistencyCop.

##### 1.00    02-Nov-2006
- Corrected unreasonable assumption of a consistent small indent setting (of 1
  or 2 spaces) when actually only some wrong spaces spoil the consistency.
  Now, a perfect consistent rating is only accepted if its absolute rating
  number is also the maximum rating.
- BF: Avoiding runtime error in IndentBufferInconsistencyCop() if s:ratings is
  empty.
- BF: Suppressing 'Not buffer setting' option if the buffer setting is
  inconsistent ('badset'), which threw an exception when selected.

##### 1.00    30-Oct-2006
- Improved g:indentconsistencycop\_non\_indent\_pattern to also allow ' \*\\t' and '
!!!\*\*' comments.

##### 1.00    24-Oct-2006
- First published version.

##### 0.01    08-Oct-2006
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2006-2020 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
