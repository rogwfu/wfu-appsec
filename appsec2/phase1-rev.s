push    ebp             ; Alternative name is 'gcc2_compiled.'
mov     ebp, esp
sub     esp, 8
mov     eax, [ebp+arg_0]
add     esp, 0FFFFFFF8h
push    offset aPublicSpeaking ; "Public speaking is very easy."
push    eax
call    strings_not_equal
add     esp, 10h
test    eax, eax
jz      short loc_8048B43
call    explode_bomb
