#!/bin/bash

mkdir -p compiled images

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done


echo "Concat the transducer 'horas' with the transducer 'aux_e'"
fstconcat compiled/horas.fst compiled/aux_e.fst compiled/horas_e.fst

echo "Concat the transducer 'horas_e' with the transducer 'minutos'"
fstconcat compiled/horas_e.fst compiled/minutos.fst compiled/text2num.fst

echo "Concat the transducer 'horas' with the transducer 'aux_e_eps'"
fstconcat compiled/horas.fst compiled/aux_e_eps.fst compiled/horas_e_eps.fst

echo "Concat the transducer 'horas_e_eps' with the transducer 'minutos'"
fstconcat compiled/horas_e_eps.fst compiled/minutos.fst compiled/lazy2num.fst

echo "Invert the transducer 'horas' to the transducer 'horas_inverted'"
fstinvert compiled/horas.fst compiled/horas_inverted.fst

echo "Invert the transducer 'minutos' to the transducer 'minutos_inverted'"
fstinvert compiled/minutos.fst compiled/minutos_inverted.fst

echo "Invert the transducer 'aux_e' to the transducer 'aux_e_inverted'"
fstinvert compiled/aux_e.fst compiled/aux_e_inverted.fst

echo "Concat the transducer 'horas_inverted' with the transducer 'aux_e_inverted'"
fstconcat compiled/horas_inverted.fst compiled/aux_e_inverted.fst compiled/horas_e_inverted.fst

echo "Concat the transducer 'horas_e_inverted' with the transducer 'minutos_inverted'"
fstconcat compiled/horas_e_inverted.fst compiled/minutos_inverted.fst compiled/num2text.fst

echo "Project the transducer 'horas' into 'horas_input'"
fstproject compiled/horas.fst compiled/horas_input.fst

echo "Project the transducer 'aux_e' into 'aux_e_input'"
fstproject compiled/aux_e.fst compiled/aux_e_input.fst

echo "Unify the transducer 'meias' with the transducer 'quartos' into 'meias_ou_quartos'"
fstunion compiled/meias.fst compiled/quartos.fst compiled/meias_ou_quartos.fst

echo "Concat the transducer 'horas_input' with the transducer 'aux_e_input'"
fstconcat compiled/horas_input.fst compiled/aux_e_input.fst compiled/horas_e_input.fst

echo "Concat the transducer 'horas_e_input' with the transducer 'meias_ou_quartos'"
fstconcat compiled/horas_e_input.fst compiled/meias_ou_quartos.fst compiled/rich2text.fst

echo "Composing the transducer 'quartos' with the input 'minutos.txt'"
fstcompose compiled/quartos.fst compiled/minutos.fst compiled/quartos_composed.fst

echo "Composing the transducer 'meias' with the input 'minutos.txt'"
fstcompose compiled/meias.fst compiled/minutos.fst compiled/meias_composed.fst

echo "Unify the transducer 'meias_composed' with the transducer 'quartos_composed' into 'meias_ou_quartos_composed'"
fstunion compiled/meias_composed.fst compiled/quartos_composed.fst compiled/meias_ou_quartos_composed.fst

echo "Unify the transducer 'meias_ou_quartos' with the transducer 'minutos' into 'minutos_meias_ou_quartos'"
fstunion compiled/meias_ou_quartos_composed.fst compiled/minutos.fst compiled/minutos_meias_ou_quartos.fst

echo "Concat the transducer 'horas_e_eps' with the transducer 'minutos_meias_ou_quartos'"
fstconcat compiled/horas_e_eps.fst compiled/minutos_meias_ou_quartos.fst compiled/rich2num.fst


for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done


echo "Testing the transducer 'horas' with the input 'tests/test_horas.txt'"
fstcompose compiled/test_horas.fst compiled/horas.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

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

echo "Testing the transducer 'rich2num' with the input 'tests/sleepB94129.txt'"
fstcompose compiled/sleepB94129.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/wakeupB94129.txt'"
fstcompose compiled/wakeupB94129.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/sleepA94129.txt'"
fstcompose compiled/sleepA94129.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/wakeupA94129.txt'"
fstcompose compiled/wakeupA94129.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
