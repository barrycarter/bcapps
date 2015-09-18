imageOBJS=$(echo *.c | perl -pnle 's%^(.*?)\.c%/home/barrycarter/bin/$1%isg')
echo $imageOBJS
# converts all PDFs to text
imageOBJS=$(shell echo *.pdf | perl -pnle 's/\.pdf/.pdf.txt/isg')
all: $(imageOBJS)
echo $all
