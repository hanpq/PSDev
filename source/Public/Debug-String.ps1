<#

  Prerequisites: PowerShell v5.1 and above (verified; may also work in earlier versions)
  License: MIT
  Author:  Michael Klement <mklement0@gmail.com>

#>

function Debug-String
{

    <#
        .SYNOPSIS
        Outputs a string in diagnostic form or as source code.

        .DESCRIPTION

        Author:  Michael Klement

        Prints a string with control or hidden characters visualized, and optionally
        all non-ASCII-range Unicode characters represented as escape sequences.

        With -AsSourceCode, the result is printed in single-line form as a
        double-quoted PowerShell string literal that is reusable as source code,

        Common control characters are visualized using PowerShell's own escaping
        notation by default, such as
        "`t" for a tab, "`r" for a CR, but a LF is visualized as itself, as an
        actual newline, unless you specify -SingleLine.

        As an alternative, if you want ASCII-range control characters visualized in caret notation
        (see https://en.wikipedia.org/wiki/Caret_notation), similar to cat -A on Linux,
        use -CaretNotation. E.g., ^M then represents a CR; but note that a LF is
        always represented as "$" followed by an actual newline.

        Any other control characters as well as otherwise hidden characters or
        format / punctuation characters in the non-ASCII range are represented in
        `u{hex-code-point} notation.

        To print space characters as themselves, use -NoSpacesAsDots.

        $null inputs are accepted, but a warning is issued.

        .PARAMETER InputObject
        Defines the string to analyze

        .PARAMETER CaretNotation
        Causes LF to be visualized as "$" and all other ASCII-range control characters
        in caret notation, similar to `cat -A` on Linux.

        .PARAMETER Delimiters
        You may optionally specify delimiters that the visualization of each input string is enclosed
        in as a a whole its boundaries. You may specify a single string or a 2-element array.

        .PARAMETER NoSpacesAsDots
        By default, space chars. are visualized as "·", the MIDDLE DOT char. (U+00B7)

        Use this switch to represent spaces as themselves.

        .PARAMETER NoEmphasis
        By default, those characters (other than spaces) that aren't output as themselves,
        i.e. control characters and, if requested with -UnicodeEscapes, non-ASCII-range characters,
        are highlighted by color inversion, using ANSI (VT) escape sequences.

        Use this switch to turn off this highlighting.

        Note that if $PSStyle.OutputRendering = 'PlainText' is in effect, the highlighting
        isn't *shown* even *without* -NoEmphasis, but the escape sequences are still part
        of the output string. Only -NoEmphasis prevents inclusion of these escape sequences.

        .PARAMETER AsSourceCode
        Outputs each input string as a double-quoted PowerShell string
        that is reusable in source code, with embedded double quotes, backticks,
        and "$" signs backtick-escaped.

        Use -SingleLine to get a single-line representation.
        Control characters that have no native PS escape sequence are represented
        using `u{<hex-code-point} notation, which will only work in PowerShell *Core*
        (v6+) source code.

        .PARAMETER SingleLine
        Requests a single-line representation, where LF characters are represented
        as `n instead of actual line breaks.

        .PARAMETER UnicodeEscapes
        Requests that all non-ASCII-range characters - such as accented letters -  in
        the input string be represented as Unicode escape sequences in the form
        `u{hex-code-point}.

        Whe cominbed with -AsSourceCode, the result is a PowerShell string literal
        composed of ASCII-range characters only, but note that only PowerShell *Core*
        (v6+) understands such Unicode escapes.

        By default, only control characters that don't have a native PS escape
        sequence / cannot be represented with caret notation are represented this way.

        .EXAMPLE
        PS> "a`ab`t c`0d`r`n" | Debug-String -Delimiters [, ]
        [a`0b`t·c`0d`r`
        ]

        .EXAMPLE
        PS> "a`ab`t c`0d`r`n" | Debug-String -CaretNotation
        a^Gb^I c^@d^M$

        .EXAMPLE
        PS> "a-ü`u{2028}" | Debug-String -UnicodeEscapes # The dash is an em-dash (U+2014)
        a·`u{2014}·`u{fc}

        .EXAMPLE
        PS> "a`ab`t c`0d`r`n" | Debug-String -AsSourceCode -SingleLine # roundtrip
        "a`ab`t c`0d`r`n"
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'NoSpacesAsDots', Justification = 'False positive')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'NoEmphasis', Justification = 'False positive')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'SingleLine', Justification = 'False positive')]
    [CmdletBinding(DefaultParameterSetName = 'Standard', PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = 'Standard', Position = 0)]
        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = 'Caret', Position = 0)]
        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = 'AsSourceCode', Position = 0)]
        [AllowNull()]
        [object[]] $InputObject,

        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'Caret')]
        [string[]] $Delimiters, # for enclosing the visualized strings as a whole - probably rarely used.

        [Parameter(ParameterSetName = 'Caret')]
        [switch] $CaretNotation,

        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'Caret')]
        [switch] $NoSpacesAsDots,
        [Parameter(ParameterSetName = 'Caret')]
        [Parameter(ParameterSetName = 'Standard')]
        [switch] $NoEmphasis,

        [Parameter(ParameterSetName = 'AsSourceCode')]
        [switch] $AsSourceCode,

        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'AsSourceCode')]
        [switch] $SingleLine,

        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'Caret')]
        [Parameter(ParameterSetName = 'AsSourceCode')]
        [switch] $UnicodeEscapes

    )

    begin
    {
        $esc = [char] 0x1b
        if ($UnicodeEscapes)
        {
            $re = [regex] '(?s).' # We must look at *all* characters.
        }
        else
        {
            # Only control / separator / punctuation chars.
            # * \p{C} matches any Unicode control / format/ invisible characters, both inside and outside
            #   the ASCII range; note that tabs (`t) are control character too, but not spaces; it comprises
            #   the following Unicode categories: Control, Format, Private_Use, Surrogate, Unassigned
            # * \p{P} comprises punctuation characters.
            # * \p{Z} comprises separator chars., including spaces, but not other ASCII whitespace, which is in the Control category.
            # Note: For -AsSourceCode we include ` (backticks) too.
            $re = if ($AsSourceCode)
            {
                [regex] '[`\p{C}\p{P}\p{Z}]'
            }
            else
            {
                [regex] '[\p{C}\p{P}\p{Z}]'
            }
        }
        $openingDelim = $closingDelim = ''
        if ($Delimiters)
        {
            $openingDelim = $Delimiters[0]
            $closingDelim = $Delimiters[1]
            if (-not $closingDelim)
            {
                $closingDelim = $openingDelim
            }
        }
    }
    process
    {
        if ($null -eq $InputObject)
        {
            Write-Warning 'Ignoring $null input.'; return
        }
        foreach ($str in $InputObject)
        {
            if ($null -eq $str)
            {
                Write-Warning 'Ignoring $null input.'; continue
            }
            if ($str -isnot [string])
            {
                $str = -join ($str | Out-String -Stream)
            }
            $strViz = $re.Replace($str, {
                    param($match)
                    $char = [char] $match.Value[0]
                    $codePoint = [uint16] $char
                    $sbToUnicodeEscape = { '`u{' + '{0:x}' -f [int] $Args[0] + '}' }
                    # wv -v ('in [{0}]' -f [char] $match.Value)
                    $vizChar =
                    if ($CaretNotation)
                    {
                        if ($codePoint -eq 0xA)
                        {
                            # LF -> $<newline>
                            '$' + $char
                        }
                        elseif ($codePoint -eq 0x20)
                        {
                            # space char.
                            if ($NoSpacesAsDots)
                            {
                                ' '
                            }
                            else
                            {
                                '·'
                            }
                        }
                        elseif ($codePoint -ge 0 -and $codePoint -le 31 -or $codePoint -eq 127)
                        {
                            # If it's a control character in the ASCII range,
                            # use caret notation too (C0 range).
                            # See https://en.wikipedia.org/wiki/Caret_notation
                            '^' + [char] ((64 + $codePoint) -band 0x7f)
                        }
                        elseif ($codePoint -ge 128)
                        {
                            # Non-ASCII (control) character -> `u{<hex-code-point>}
                            & $sbToUnicodeEscape $codePoint
                        }
                        else
                        {
                            $char
                        }
                    }
                    else
                    {
                        # -not $CaretNotation
                        # Translate control chars. that have native PS escape sequences
                        # into these escape sequences.
                        switch ($codePoint)
                        {
                            0
                            {
                                '`0'; break
                            }
                            7
                            {
                                '`a'; break
                            }
                            8
                            {
                                '`b'; break
                            }
                            9
                            {
                                '`t'; break
                            }
                            11
                            {
                                '`v'; break
                            }
                            12
                            {
                                '`f'; break
                            }
                            10
                            {
                                if ($SingleLine)
                                {
                                    '`n'
                                }
                                else
                                {
                                    "`n"
                                }; break
                            }
                            13
                            {
                                '`r'; break
                            }
                            27
                            {
                                '`e'; break
                            }
                            32
                            {
                                if ($AsSourceCode -or $NoSpacesAsDots)
                                {
                                    ' '
                                }
                                else
                                {
                                    '·'
                                }; break
                            } # Spaces are visualized as middle dots by default.
                            default
                            {
                                # Note: 0x7f (DELETE) is technically still in the ASCII range, but it is a control char. that should be visualized as such
                                #       (and has no dedicated escape sequence).
                                if ($codePoint -ge 0x7f)
                                {
                                    & $sbToUnicodeEscape $codePoint
                                }
                                elseif ($AsSourceCode -and $codePoint -eq 0x60)
                                {
                                    # ` (backtick)
                                    '``'
                                }
                                else
                                {
                                    $char
                                }
                            }
                        } # switch
                    }
                    # Return the visualized character.
                    if (-not ($NoEmphasis -or $AsSourceCode) -and $char -ne ' ' -and $vizChar -cne $char)
                    {
                        # Highlight a visualized character that isn't visualized as itself (apart from spaces)
                        # by inverting its colors, using VT / ANSI escape sequences
                        "$esc[7m$vizChar$esc[m"
                    }
                    else
                    {
                        $vizChar
                    }
                }) # .Replace

            # Output
            if ($AsSourceCode)
            {
                '"{0}"' -f ($strViz -replace '"', '`"' -replace '\$', '`$')
            }
            else
            {
                if ($CaretNotation)
                {
                    # If a string *ended* in a newline, our visualization now has
                    # a trailing LF, which we remove.
                    $strViz = $strViz -replace '(?s)^(.*\$)\n$', '$1'
                }
                $openingDelim + $strViz + $closingDelim
            }
        }
    } # process

} # function
