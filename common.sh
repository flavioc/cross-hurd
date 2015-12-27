fix_gcc_path() {
   echo -en "\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 \"${SYS_ROOT}/lib/\"\n" >> gcc/config/gnu.h &&
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/gnu.h
}

