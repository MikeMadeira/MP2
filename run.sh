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

echo "Concat the transducer 'hours' with the transducer 'aux_e_eps'"
fstconcat compiled/hours.fst compiled/aux_e_eps.fst compiled/hours_e_eps.fst

echo "Concat the transducer 'hours_e_eps' with the transducer 'minutos'"
fstconcat compiled/hours_e_eps.fst compiled/minutos.fst compiled/lazy2num.fst

echo "Invert the transducer 'hours' to the transducer 'hours_inverted'"
fstinvert compiled/hours.fst compiled/hours_inverted.fst

echo "Invert the transducer 'minutos' to the transducer 'minutos_inverted'"
fstinvert compiled/minutos.fst compiled/minutos_inverted.fst

echo "Invert the transducer 'aux_e' to the transducer 'aux_e_inverted'"
fstinvert compiled/aux_e.fst compiled/aux_e_inverted.fst

echo "Concat the transducer 'hours_inverted' with the transducer 'aux_e_inverted'"
fstconcat compiled/hours_inverted.fst compiled/aux_e_inverted.fst compiled/hours_e_inverted.fst

echo "Concat the transducer 'hours_e_inverted' with the transducer 'minutos_inverted'"
fstconcat compiled/hours_e_inverted.fst compiled/minutos_inverted.fst compiled/num2text.fst

echo "Project the transducer 'hours' into 'hours_input'"
fstproject compiled/hours.fst compiled/hours_input.fst

echo "Project the transducer 'aux_e' into 'aux_e_input'"
fstproject compiled/aux_e.fst compiled/aux_e_input.fst

echo "Unify the transducer 'meias' with the transducer 'quartos' into 'meias_ou_quartos'"
fstunion compiled/meias.fst compiled/quartos.fst compiled/meias_ou_quartos.fst

echo "Concat the transducer 'hours_input' with the transducer 'aux_e_input'"
fstconcat compiled/hours_input.fst compiled/aux_e_input.fst compiled/hours_e_input.fst

echo "Concat the transducer 'hours_e_input' with the transducer 'meias_ou_quartos'"
fstconcat compiled/hours_e_input.fst compiled/meias_ou_quartos.fst compiled/rich2text.fst

echo "Composing the transducer 'quartos' with the input 'minutos.txt'"
fstcompose compiled/quartos.fst compiled/minutos.fst compiled/quartos_composed.fst

echo "Composing the transducer 'meias' with the input 'minutos.txt'"
fstcompose compiled/meias.fst compiled/minutos.fst compiled/meias_composed.fst

echo "Unify the transducer 'meias_composed' with the transducer 'quartos_composed' into 'meias_ou_quartos_composed'"
fstunion compiled/meias_composed.fst compiled/quartos_composed.fst compiled/meias_ou_quartos_composed.fst

echo "Unify the transducer 'meias_ou_quartos' with the transducer 'minutos' into 'minutos_meias_ou_quartos'"
fstunion compiled/meias_ou_quartos_composed.fst compiled/minutos.fst compiled/minutos_meias_ou_quartos.fst

echo "Concat the transducer 'hours_e_eps' with the transducer 'minutos_meias_ou_quartos'"
fstconcat compiled/hours_e_eps.fst compiled/minutos_meias_ou_quartos.fst compiled/rich2num.fst


for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

echo "Testing the transducer 'converter' with the input 'tests/numero.txt'"
fstcompose compiled/numero.fst compiled/converter.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'trans_teste' with the input 'tests/teste1.txt'"
fstcompose compiled/teste1.fst compiled/trans_teste.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'hours' with the input 'tests/test_hours.txt'"
fstcompose compiled/test_hours.fst compiled/hours.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'minutos' with the input 'tests/test_minutos.txt'"
fstcompose compiled/test_minutos.fst compiled/minutos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'meias' with the input 'tests/test_meias.txt'"
fstcompose compiled/test_meias.fst compiled/meias.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'quartos' with the input 'tests/test_quartos.txt'"
fstcompose compiled/test_quartos.fst compiled/quartos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'text2num' with the input 'tests/test_text2num.txt'"
fstcompose compiled/test_text2num.fst compiled/text2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'lazy2num' with the input 'tests/test_lazy2num.txt'"
fstcompose compiled/test_lazy2num.fst compiled/lazy2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2text' with the input 'tests/test_rich2text.txt'"
fstcompose compiled/test_rich2text.fst compiled/rich2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/test_rich2num.txt'"
fstcompose compiled/test_rich2num.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/sleepA94129.txt'"
fstcompose compiled/sleepA94129.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
