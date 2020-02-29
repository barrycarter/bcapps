#!/bin/perl

# converts a CSV file to a LaTeX table (very basic, probably need to
# edit table after creation)

require "/usr/local/lib/bclib.pl";




=item comment

Reference:

\begin{array}{|c|c|c|}
\hline
\textbf{Name} & \textbf{# Eclipses} & \textbf{Per} &
\textbf{Shortest} & \textbf{Mean} & \textbf{Longest} & \textbf{Time} \\
\textbf{(NAIF id)} & \textbf{(1850-2099)} & \textbf{Annum} &
\textbf{(seconds)} & \textbf{(seconds)} & \textbf{(seconds)} & \textbf{%age} \\
\hline
\text{Io (501)} & \text{51,592} & \text{206} & \text{7555} & \text{7817} &
\text{8072} & \text{5.4%} \\
\hline
\text{Europa (502)} & \text{25,692} & \text{103} & \text{8665} & \text{9381} &
\text{10221} & \text{3.1%} \\
\hline
\text{Ganymede (503)} & \text{12,742} & \text{51} & \text{5656} & \text{9846} &
\text{12565} & \text{1.6%} \\
\hline
\text{Callisto (504)} & \text{2804} & \text{11} & \text{273} & \text{12552} &
\text{16668} & \text{0.4%} \\
\hline
\end{array}

=cut
