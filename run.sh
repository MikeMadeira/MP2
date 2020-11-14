#!/bin/bash

mkdir -p compiled images

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done


echo "Concat the transducer 'hours' with the transducer 'aux_e'"
fstconcat compiled/hours.fst compiled/aux_e.fst compiled/hours_e.fst

echo "Concat the transducer 'hours_e' with the transducer 'minutos'"
fstconcat compiled/hours_e.fst compiled/minutos.fst compiled/text2num.fst


for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

echo "Testing the transducer 'converter' with the input 'tests/numero.txt'"
fstcompose compiled/numero.fst compiled/converter.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'hours' with the input 'tests/sleepB94129.txt'"
fstcompose compiled/sleepB94129.fst compiled/hours.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'minutos' with the input 'tests/wakeupB94129.txt'"
fstcompose compiled/wakeupB94129.fst compiled/minutos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'meias' with the input 'tests/wakeupA94129.txt'"
fstcompose compiled/wakeupA94129.fst compiled/meias.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'trans_teste' with the input 'tests/teste1.txt'"
fstcompose compiled/teste1.fst compiled/trans_teste.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'text2num' with the input 'tests/sleepB94129.txt'"
fstcompose compiled/sleepB94129.fst compiled/text2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt