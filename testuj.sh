#!/bin/bash
cd "$(dirname "$0")"
echo ----KOMPILACJA----
echo Kompiluję program projektu
touch tmp
gcc -std=c17 -pedantic -Wall -Wextra -Wformat-security -Wduplicated-cond -Wfloat-equal -Wshadow -Wconversion -Wjump-misses-init -Wlogical-not-parentheses -Wnull-dereference -Wvla -Werror -fstack-protector-strong -fsanitize=undefined -fno-sanitize-recover -g -fno-omit-frame-pointer -O1 project.c -o project -lm

if [ "$?" -ne "0" ]; then
   echo !!! BŁĄD KOMPILACJI !!!;
   exit;
fi
printf "\n"

echo ----TESTOWANIE----
for file in tests/in/*
do
    echo -"$(basename $file)"-
    command=$(valgrind --leak-check=full -q --error-exitcode=1 ./project <$file | diff - tests/out/$(basename -s .in $file).out)
    if [ -z $command ]; then
        printf "Pomyślnie ukończono próbę "$(basename -s .in $file)"."
        time(./project <$file >tmp)
        echo
    else
        echo !-!-! Błąd !-!-!
        echo Błędny wynik podczas wykonywania próby "$(basename $file)"
        echo Spodziewany wynik: 
        cat tests/out/$(basename -s .in $file).out
        echo Otrzymany wynik:
        valgrind --leak-check=full -q --error-exitcode=1 ./project <$file
        break
    fi
done

echo ----CZYSZCZENIE----
echo Usuwam plik wykonywalny projektu
rm project
rm tmp
printf "\n"
echo ----ZAKOŃCZENIE PROCESU TESTOWANIA----
echo Dziękujemy za skorzystanie z programu testującego!
