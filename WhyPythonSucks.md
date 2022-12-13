  - Hashes are called dictionaries

  - Whitespace is significant, making it difficult to comment out code
  for testing

  - In hash creation, disallows {color: "red"} to mean {"color": "red"}

  - Uses "//" for integer division, many other languages use it as a comment

  - `for (int i=0; i<=10; i++) {print(i);}` doesn't work, even using Bython

  - Can't easily load libraries in other directories `import "../bclib.py"` does not work

  - To get array length isn't arr.len, arr.length, arr.length(), but len(arr)

  - No ++ operator

  - dict[1][2] doesn't mean the same thing as dict[1,2]

  - dict[1][2] won't create dict[1] if needed

  - doesn't allow 'a || b' 'a && b' and '!a'

  - in PIL, image.setpixel is image.putpixel

  - foo.map(fun) doesn't work, need map(fun, foo)

  - strftime takes arguments in wrong order (compared to other languages)

  - no generic "str2time" function: instead, must use complicated strptime() function

  - changing the value of a variable changes its id/pointer:

a = 2; id(a); a = 3; id(a)

  - functions must be defined before use, unlike in other languages where the interpreter is smart enough to sort/order the definitions correctly; particularly painful if two functions depend on each other

  - setting `a = b` only sets a pointer if a and b are non-simple objects; while many languages do this, it's confusing for a supposedly easy-to-learn language
