echo "compilando..."
make -f Makefile
echo "gerando MEPA..."
./compilador $1 
#if [ $? == 0 ]; then
#    simulaMepa
#fi
