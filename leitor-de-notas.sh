#!/bin/bash
#
# Version.: 202412181310
# Creation: 11-12-2024
# Author..: braga[dot]marcos[at]gmail[dot]com
#
# Variables -----------------------------------------------
this_file=$(basename -s .sh $0)
this_file_aux=$this_file.aux
file_pdf=${1}
dev_null=/dev/null
# ---------------------------------------------------------
# Validanting ---------------------------------------------
while [ -z $file_pdf ]; do
  read -p "PDF File Name: " file_pdf
  if [ -f "${file_pdf}" ]; then
    echo File ok
  else
    echo File does not exist
    unset file_pdf
  fi
done
file_txt=${file_pdf%%'.'*}.txt
# ---------------------------------------------------------
# Requirements --------------------------------------------
# dnf install poppler-utils -y
# ---------------------------------------------------------
function verifyApp {
  local app_name=${1}
  if rpm -qi $app_name >$dev_null; then
    ret=true
  else
    ret=false
  fi
$ret
}

if verifyApp poppler-utils; then
  # Converting pdf file to text file
  pdftotext -layout -nopgbrk $file_pdf
  # Removing bad caracthers -----------------------------
  strings $file_txt > $this_file_aux && mv $this_file_aux $file_txt
  # Validating NOMAD file
  file_txt_head=$(head -n1 $file_txt | sed 's/\ //g')
  if [ "NOMAD" == "$file_txt_head" ]; then
    # Get Buy and Sell events ---------------------------------------------------------------------
    awk '/(Buy|Sell)/' $file_txt > $this_file_aux && mv $this_file_aux $file_txt
    # [BUY] Extracting stocks names
    awk -F"Buy" '/Buy/ {print $1}' $file_txt | awk '{print $1,"C"}' > aux1
    # [BUY] Extracting stocks data v1 before 11/2024
    #awk -F"Buy" '/Buy/ {print $2}' $file_txt | awk '{print $1,$2,$3}' | sed 's/\./\,/g' > aux2
    # [BUY] Extracting stocks data v2
    awk -F"Buy" '/Buy/ {print $2}' $file_txt | awk '{print $3,$4,$5}' | sed 's/\./\,/g' > aux2
    # [BUY] Join stock names and data
    > data.txt paste aux1 aux2
    # [SELL] Extracting stocks names
    awk -F"Sell" '/Sell/ {print $1}' $file_txt | awk '{print $1,"V"}' > aux1
    # [SELL] Extracting stocks data v1 before 11/2024
    #awk -F"Sell" '/Sell/ {print $2}' $file_txt | awk '{print $1,$2,$3}' | sed 's/\./\,/g' > aux2
    # [SELL] Extracting stocks data v2
    awk -F"Sell" '/Sell/ {print $2}' $file_txt | awk '{print $3,$4,$5}' | sed 's/\./\,/g' > aux2
    # [SELL] Join stock names and data
    >> data.txt paste aux1 aux2
    while read STK OPE VLR PRC DTE; do
      # Ajust date to BR
      day=$(echo $DTE | cut -d"/" -f2) && [ $day -lt 10 ] && day=0$day
      month=$(echo $DTE | cut -d"/" -f1) && [ $month -lt 10 ] && month=0$month
      year=$(echo $DTE | cut -d"/" -f3)
      DTE=${day}/${month}/${year}
      echo -e "$STK;$DTE;$OPE;$VLR;$PRC;0,00;NOMAD;0,00;USD"
    done < data.txt
    resultado="Done"
  else
  	resultado="Nao e um arquivo NOMAD"
  fi
else
  resultado="poppler-utils not found, please install first."
fi

echo $resultado

# Ending
[ -f $this_file_aux ] && rm $this_file_aux
[ -f aux1 ] && rm aux1
[ -f aux2 ] && rm aux2
[ -f data.txt ] && rm data.txt
[ -f $file_txt ] && rm $file_txt
exit 0
# ---------------------------------------------------------