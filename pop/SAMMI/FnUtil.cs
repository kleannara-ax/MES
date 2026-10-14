using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace SAMMI
{
    class FnUtil
    {
        public static bool isDate(string date)
        {
            DateTime time;
            date = isNull(date);
            date = date.Replace("-", "").Replace("/", "");
            if ((date.Length != 8) || !isNumeric(date))
            {
                return false;
            }
            CultureInfo info = new CultureInfo(CultureInfo.CurrentCulture.Name);
            date = date.Substring(0, 4) + info.DateTimeFormat.DateSeparator + date.Substring(4, 2) + info.DateTimeFormat.DateSeparator + date.Substring(6);
            return DateTime.TryParse(date, out time);
        }

        public static string isNull(string source)
        {
            return isNull(source, "");
        }

        public static string isNull(string source, string target)
        {
            if ((source != null) && !(source == ""))
            {
                return source;
            }
            return target;
        }

        public static bool isNumeric(string source)
        {
            if (source == null)
            {
                return false;
            }
            return Regex.IsMatch(source, @"^([1-9]\d*)$|^0$");
        }
        public static bool CheckDateMinValue(string date, string minDate)
        {
            string str = "";
            string str2 = "";
            if (date.Length == 6)
            {
                str = date + "01";
            }
            if (date.Length == 4)
            {
                str = date + "0101";
            }
            if (minDate.Length == 6)
            {
                str2 = minDate + "01";
            }
            if (minDate.Length == 4)
            {
                str2 = minDate + "0101";
            }
            if (!isDate(str))
            {
                MessageBox.Show(string.Format(Common.getLangText("비교 대상 값 [{0}]이 올바른 날짜형식이 아닙니다."),date), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                return false;
            }
            if (!isDate(str2))
            {
                MessageBox.Show(string.Format(Common.getLangText("비교 값 [{0}]이 올바른 날짜형식이 아닙니다."),minDate), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                return false;
            }
            if (getDateTime(str) < getDateTime(str2))
            {
                return false;
            }
            return true;
        }

        public static DateTime getDateTime(string date)
        {
            if (!isDate(date))
            {
                return new DateTime(0x76c, 1, 1);
            }
            date = date.Replace("-", "").Replace("/", "");
            return new DateTime(int.Parse(date.Substring(0, 4)), int.Parse(date.Substring(4, 2)), int.Parse(date.Substring(6)));
        }

        public static bool CheckDateMaxValue(string date, string maxDate)
        {
            string str = "";
            string str2 = "";
            if (date.Length == 6)
            {
                str = date + "01";
            }
            if (date.Length == 4)
            {
                str = date + "0101";
            }
            if (maxDate.Length == 6)
            {
                str2 = maxDate + "01";
            }
            if (maxDate.Length == 4)
            {
                str2 = maxDate + "0101";
            }
            if (!isDate(str))
            {
                MessageBox.Show(string.Format(Common.getLangText("비교 대상 값 [{0}]이 올바른 날짜형식이 아닙니다."),date), "입력오류", MessageBoxButtons.OK, MessageBoxIcon.Hand);
                return false;
            }
            if (!isDate(str2))
            {
                MessageBox.Show(string.Format(Common.getLangText("비교 값 [{0}]이 올바른 날짜형식이 아닙니다."), maxDate), "입력오류", MessageBoxButtons.OK, MessageBoxIcon.Hand);
                return false;
            }
            if (getDateTime(str) > getDateTime(str2))
            {
                return false;
            }
            return true;
        }


        public static bool ChekcStringMaxLength(string inData, int maxLength)
        {
            if (fnStringByteLength(inData) > maxLength)
            {
                return false;
            }
            return true;
        }
        public static int fnStringByteLength(string stringLength)
        {
            return Encoding.GetEncoding(0).GetByteCount(stringLength);
        }
        public static bool isInt(string source)
        {
            int num;
            if (source == null)
            {
                return false;
            }
            return int.TryParse(source, out num);
        }

        public static bool CheckDataMinValue(int inData, int maxValue)
        {
            if (inData < maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMinValue(string inData, decimal maxValue)
        {
            if (decimal.Parse(inData) < maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMinValue(string inData, int maxValue)
        {
            if (int.Parse(inData) < maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMinValue(string inData, string maxValue)
        {
            decimal num = decimal.Parse(inData);
            decimal num2 = decimal.Parse(maxValue);
            if (num < num2)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMaxValue(int inData, int maxValue)
        {
            if (inData > maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMaxValue(string inData, decimal maxValue)
        {
            if (decimal.Parse(inData) > maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMaxValue(string inData, int maxValue)
        {
            if (int.Parse(inData) > maxValue)
            {
                return false;
            }
            return true;
        }
        public static bool CheckDataMaxValue(string inData, string maxValue)
        {
            decimal num = decimal.Parse(inData);
            decimal num2 = decimal.Parse(maxValue);
            if (num > num2)
            {
                return false;
            }
            return true;
        }

        public static bool isDecimal(string source)
        {
            decimal num;
            if (source == null)
            {
                return false;
            }
            return decimal.TryParse(source, out num);
        }
    }
}
