#!/bin/bash
# Generates progress.html from the current [CONTEXT] commit message

# Get the current commit message
COMMIT_MSG=$(git log -1 --pretty=%B)

# Check if this is a [CONTEXT] commit
if [[ ! "$COMMIT_MSG" =~ ^\[CONTEXT\] ]]; then
    echo "Not a [CONTEXT] commit, skipping HTML generation"
    exit 0
fi

# Get git info
GIT_COMMIT=$(git rev-parse HEAD)
GIT_AUTHOR=$(git log -1 --format='%an <%ae>')
GIT_DATE=$(git log -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S')

# Generate HTML from markdown commit message
cat > progress.html << 'HTML_START'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[CONTEXT] Project Progress</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            max-width: 1000px;
            margin: 0 auto;
            padding: 40px 20px;
            background: #f5f7fa;
            min-height: 100vh;
        }

        .container {
            background: white;
            padding: 50px;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
        }

        h1 {
            color: #1a1a1a;
            font-size: 2.5em;
            font-weight: 700;
            margin: 0 0 10px 0;
        }

        h1 + p {
            color: #666;
            font-size: 1.05em;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e5e7eb;
        }

        h2 {
            color: #1a1a1a;
            font-size: 1.6em;
            font-weight: 700;
            margin: 40px 0 20px 0;
            padding: 12px 16px;
            background: #fafafa;
            border-left: 4px solid #3b82f6;
            border-radius: 2px;
        }

        h3 {
            color: #374151;
            font-size: 1.15em;
            font-weight: 600;
            margin: 25px 0 15px 0;
            padding-left: 12px;
            border-left: 2px solid #d1d5db;
        }

        ul {
            list-style: none;
            padding-left: 0;
            margin: 15px 0;
        }

        li {
            margin: 8px 0;
            padding: 10px 12px 10px 35px;
            position: relative;
            border-radius: 2px;
            transition: background 0.15s ease;
            background: transparent;
            border-left: 2px solid transparent;
        }

        li:hover {
            background: #f9fafb;
        }

        .completed {
            border-left-color: #10b981;
        }

        .completed::before {
            content: "✓";
            position: absolute;
            left: 10px;
            top: 10px;
            color: #10b981;
            font-weight: 600;
            font-size: 1em;
        }

        .pending {
            border-left-color: #f59e0b;
        }

        .pending::before {
            content: "○";
            position: absolute;
            left: 10px;
            top: 10px;
            color: #f59e0b;
            font-weight: 600;
            font-size: 1em;
        }

        code {
            background: #f1f5f9;
            color: #e11d48;
            padding: 3px 8px;
            border-radius: 4px;
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            font-size: 0.9em;
            border: 1px solid #e2e8f0;
        }

        p {
            color: #4a5568;
            margin: 12px 0;
            line-height: 1.8;
        }

        .summary {
            background: #f0f9ff;
            padding: 20px;
            border-left: 3px solid #0ea5e9;
            border-radius: 2px;
            margin: 24px 0;
            border: 1px solid #bae6fd;
        }

        .summary p {
            margin: 8px 0;
        }

        .summary ul {
            margin-top: 12px;
        }

        .summary li {
            background: transparent;
            border-left-color: #0ea5e9;
        }

        .git-info {
            background: #1f2937;
            color: #f9fafb;
            padding: 16px 20px;
            border-radius: 2px;
            margin: 20px 0 30px 0;
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            font-size: 0.9em;
            line-height: 1.8;
        }

        .git-info-line {
            margin: 4px 0;
        }

        .git-info-label {
            color: #fbbf24;
            font-weight: 600;
        }

        .git-info-value {
            color: #f9fafb;
        }

        .section-card {
            background: #fafafa;
            border-radius: 2px;
            padding: 24px;
            margin: 24px 0;
            border: 1px solid #e5e7eb;
        }

        .section-card.completed {
            background: #f0fdf4;
            border-color: #86efac;
            border-left: 3px solid #10b981;
        }

        .section-card.in-progress {
            background: #fffbeb;
            border-color: #fde047;
            border-left: 3px solid #f59e0b;
        }

        .footer {
            margin-top: 50px;
            padding-top: 24px;
            border-top: 1px solid #e5e7eb;
        }

        .footer-text {
            color: #6b7280;
            font-size: 0.9em;
            margin-bottom: 8px;
        }

        .footer-command {
            background: #1f2937;
            color: #f9fafb;
            padding: 12px 16px;
            border-radius: 2px;
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            font-size: 0.85em;
            margin: 12px 0;
            border-left: 3px solid #3b82f6;
        }

        .timestamp {
            color: #9ca3af;
            font-size: 0.85em;
            margin-top: 16px;
            text-align: right;
        }

        @media (max-width: 768px) {
            body {
                padding: 20px 10px;
            }

            .container {
                padding: 30px 20px;
            }

            h1 {
                font-size: 2em;
            }

            h2 {
                font-size: 1.5em;
            }

            h3 {
                font-size: 1.2em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
HTML_START

# Parse and convert markdown to HTML
echo "$COMMIT_MSG" | awk -v commit="$GIT_COMMIT" -v author="$GIT_AUTHOR" -v date="$GIT_DATE" '
BEGIN {
    in_list = 0
    in_section = 0
    git_info_printed = 0
    skip_rest = 0
}

# Convert [CONTEXT] title to h1
NR == 1 {
    title = substr($0, 11)  # Remove "[CONTEXT] " prefix
    print "<h1>" title "</h1>"
    next
}

# Print git info after title (git log style)
NR == 2 && !git_info_printed {
    print "<div class=\"git-info\">"
    print "  <div class=\"git-info-line\"><span class=\"git-info-label\">commit</span> <span class=\"git-info-value\">" commit "</span></div>"
    print "  <div class=\"git-info-line\"><span class=\"git-info-label\">Author:</span> <span class=\"git-info-value\">" author "</span></div>"
    print "  <div class=\"git-info-line\"><span class=\"git-info-label\">Date:</span>   <span class=\"git-info-value\">" date "</span></div>"
    print "</div>"
    git_info_printed = 1
}

# Skip blank lines at start
/^[[:space:]]*$/ && NR <= 3 { next }

# Headers with section cards
/^## / {
    if (in_list) {
        print "</ul>"
        in_list = 0
    }
    if (in_section) {
        print "</div>"  # Close previous section card
    }
    title = substr($0, 4)

    # Determine section type for styling
    if (title ~ /Completed/) {
        print "<div class=\"section-card completed\">"
    } else if (title ~ /In Progress/ || title ~ /To Do/) {
        print "<div class=\"section-card in-progress\">"
    } else if (title ~ /Current State/) {
        print "<div class=\"summary\">"
        in_section = 0  # Summary uses its own div, not section-card
    } else {
        print "<div class=\"section-card\">"
    }

    print "<h2>" title "</h2>"
    if (title !~ /Current State/) {
        in_section = 1
    }
    next
}

/^### / {
    if (in_list) {
        print "</ul>"
        in_list = 0
    }
    title = substr($0, 5)
    print "<h3>" title "</h3>"
    next
}

# Checkboxes
/^[[:space:]]*- \[x\]/ {
    if (!in_list) {
        print "<ul>"
        in_list = 1
    }
    text = substr($0, index($0, "]") + 2)
    print "<li class=\"completed\">" text "</li>"
    next
}

/^[[:space:]]*- \[ \]/ {
    if (!in_list) {
        print "<ul>"
        in_list = 1
    }
    text = substr($0, index($0, "]") + 2)
    print "<li class=\"pending\">" text "</li>"
    next
}

# Regular list items
/^[[:space:]]*- / {
    if (!in_list) {
        print "<ul>"
        in_list = 1
    }
    text = substr($0, index($0, "- ") + 2)
    # Check for inline code
    gsub(/`([^`]+)`/, "<code>\\1</code>", text)
    print "<li>" text "</li>"
    next
}

# Horizontal rule - skip footer content
/^---/ {
    if (in_list) {
        print "</ul>"
        in_list = 0
    }
    # Set flag to skip remaining lines (footer content)
    skip_rest = 1
    next
}

# Skip lines after horizontal rule
skip_rest {
    next
}

# Paragraphs
/./ {
    if (in_list) {
        print "</ul>"
        in_list = 0
    }
    line = $0
    # Check for inline code
    gsub(/`([^`]+)`/, "<code>\\1</code>", line)
    print "<p>" line "</p>"
}

END {
    if (in_list) {
        print "</ul>"
    }
    if (in_section) {
        print "</div>"  # Close last section card
    }
}
' >> progress.html

# Add footer with git update instructions
cat >> progress.html << HTML_END
        <div class="footer">
            <div class="footer-text">Update this commit via rebase as work progresses.</div>
            <div class="footer-command">git branch -f context-progress HEAD</div>
            <div class="timestamp">Generated: $(date '+%Y-%m-%d %H:%M:%S')</div>
        </div>
    </div>
</body>
</html>
HTML_END

echo "✅ Generated progress.html"
