#!/bin/bash
#
# Version.: 202412191730
# Creation: 11-12-2024
# Author..: braga[dot]marcos[at]gmail[dot]com
#
# Variables -----------------------------------------------
this_file=$(basename -s .sh $0)
file_aux0=$this_file.aux0
file_aux1=$this_file.aux1
file_aux2=$this_file.aux2
file_data=$this_file.data
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
# Function to export Buy data ---------------------------------------------------------------------
function exportBuy {
  local _file_in=${1}
  if grep -q Buy $_file_in; then
    local _columnA=$(awk -F"Buy" '/Buy/ {print $1}' $_file_in | awk '{print $1,"C"}')
    # v1 before 11-2024
    #local _columnB=$(awk -F"Buy" '/Buy/ {print $2}' $_file_in | awk '{print $1,$2,$3}' | sed 's/\./\,/g')
    # v2 after 11-2024
    local _columnB=$(awk -F"Buy" '/Buy/ {print $2}' $_file_in | awk '{print $3,$4,$5}' | sed 's/\./\,/g')
    paste <(echo "$_columnA") <(echo "$_columnB") --delimiters " "
  fi
}
# -------------------------------------------------------------------------------------------------
# Function to export Sell data --------------------------------------------------------------------
function exportSell {
  local _file_in=${1}
  if grep -q Sell $_file_in; then
    local _columnA=$(awk -F"Sell" '/Sell/ {print $1}' $_file_in | awk '{print $1,"V"}')
    # v1 before 11-2024
    #local _columnB=$(awk -F"Sell" '/Sell/ {print $2}' $_file_in | awk '{print $1,$2,$3}' | sed 's/\./\,/g')
    # v2 after 11-2024
    local _columnB=$(awk -F"Sell" '/Sell/ {print $2}' $_file_in | awk '{print $1,$2,$3}' | sed 's/\./\,/g')
    paste <(echo "$_columnA") <(echo "$_columnB") --delimiters " "
  fi
}
# -------------------------------------------------------------------------------------------------
if verifyApp poppler-utils; then
  # Converting pdf file to text file --------------------------------------------------------------
  pdftotext -layout -nopgbrk $file_pdf
  # Removing bad caracthers -----------------------------------------------------------------------
  strings $file_txt > $file_aux0 && mv $file_aux0 $file_txt
  # Validating NOMAD file -------------------------------------------------------------------------
  file_txt_head=$(head -n1 $file_txt | sed 's/\ //g')
  if [ "NOMAD" == "$file_txt_head" ]; then
    # Get Buy and Sell events ---------------------------------------------------------------------
    awk '/(Buy|Sell)/' $file_txt > $file_aux0 && mv $file_aux0 $file_txt
    # Extracting Buy data -------------------------------------------------------------------------
    > ${file_data} exportBuy $file_txt
    # extracting Sell data ------------------------------------------------------------------------
    >> ${file_data} exportSell $file_txt
    # Data out ------------------------------------------------------------------------------------
    echo "Converting $file_pdf"
    while read _stock _operation _value _price _date; do
      # Ajust date to BR --------------------------------------------------------------------------
      _day=$(echo $_date | cut -d"/" -f2) && [ $_day -lt 10 ] && _day=0$_day
      _month=$(echo $_date | cut -d"/" -f1) && [ $_month -lt 10 ] && _month=0$_month
      _year=$(echo $_date | cut -d"/" -f3)
      _date=${_day}/${_month}/${_year}
      # Data out ----------------------------------------------------------------------------------
      echo -e "$_stock;$_date;$_operation;$_value;$_price;0,00;NOMAD;0,00;USD"
    done < ${file_data}
    resultado="Done"
  else
    resultado="This is not a NOMAD file"
  fi
else
  resultado="poppler-utils not found, please install it first."
fi

echo $resultado

# Ending
[ -f $file_aux0 ] && rm $file_aux0
[ -f $file_aux1 ] && rm $file_aux1
[ -f $file_aux2 ] && rm $file_aux2
[ -f ${file_data} ] && rm ${file_data}
[ -f $file_txt ] && rm $file_txt
exit 0
# ---------------------------------------------------------
