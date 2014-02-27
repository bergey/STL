STL is a simple file format for representing 3D objects as the
triangles which form their surface. It is common in 3D printing
workflows.

This haskell library provides parsing and serialization to the ASCII
STL format. Binary support is in progress; HEAD has output but not
input.

Documentation for the last release is
[on Hackage](http://hackage.haskell.org/package/STL).

You should use the binary output format for all but very small files,
if possible.  Bug me if you need binary input or ASCII output that
doesn't overflow the stack.

Bug reports, patches, and examples of use are welcome.
