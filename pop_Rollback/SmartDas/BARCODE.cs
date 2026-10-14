using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SmartDas
{
    class BARCODE
    {

        #region "CODE128"
        /// <summary>
        /// 바코드산출값
        /// </summary>
        /// <param name="pstrBARCODE">값</param>
        /// <param name="pstrCOD">A / B / C</param>
        /// <param name="pstrERR">에러내용</param>
        /// <returns>바코드산출값(ttf에 적용할것)</returns>
        public string CODE128(string pstrBARCODE, string pstrCOD, ref string pstrERR)
        {
            string strrb = "";
            try
            {
                string strSUM = "";

                int intSTA = 203; //START Code A : 203  208  248   : 103
                //START Code B : 204 [209] 249   : 104
                //START Code C : 205  210  250   : 105
                int intEND = 211; // STOP Pattern: 206 [211] 251

                int intSUM = 0;
                int intMMM = 0;
                int intpBARCODE = 0;
                int intSOD = 0;
                const int INIT_MODE = 103;

                #region "A,B,C 바코드분류"

                // START / END FONTCODE
                switch (pstrCOD)
                {
                    case "B":          // Code128-B
                        intSTA = 209; //209
                        intEND = 211; //211
                        break;
                    case "C":          // Code128-C
                        intSTA = 210;
                        intEND = 211;
                        break;
                    default:           // Code128-A
                        intSTA = 208;
                        intEND = 211;
                        break;
                }
                #endregion //A,B,C 바코드분류



                // CHECK시작값
                #region "MOD VALUES"
                //INIT_MODE = 103;
                switch (intSTA)
                {
                    case 203:
                    case 208:
                    case 248:
                        intSOD = 103;   // Code128-A
                        break;

                    case 204:
                    case 209:
                    case 249:
                        intSOD = 104;   // Code128-B
                        break;

                    case 205:
                    case 210:
                    case 250:
                        intSOD = 105;   // Code128-C
                        break;

                }
                #endregion // MOD VALUES



                #region "바코드데이터 유효값 확인"
                intpBARCODE = pstrBARCODE.Length;
                if (intpBARCODE < 1) { pstrERR = "데이터영역이 없습니다."; return strrb; }


                for (int i = 0; i < intpBARCODE; i++)
                {
                    //Console.WriteLine(pstrBARCODE[i].ToString());

                    if ((pstrBARCODE[i] < 32) || (pstrBARCODE[i] > 126))
                    {
                        pstrERR = "데이터로 쓰지 못하는값이 포함되어있습니다 [ " + pstrBARCODE[i].ToString() + " ]";
                        return strrb;
                    }

                }
                #endregion //바코드데이터 유효값 확인

                #region "체크썸"
                intSUM = intSOD;
                for (int i = 0; i < intpBARCODE; i++)
                {
                    int intVAL = 0;
                    intVAL = pstrBARCODE[i];
                    intVAL = intVAL - 32;    //Code -> Value 변경
                    //Console.WriteLine(intVAL.ToString());

                    intSUM = intSUM + intVAL * (i + 1);
                }
                intMMM = intSUM % INIT_MODE;

                // (intMMM + 32) 값이 127 미만이면 아스키코드값을 사용하고, 127 이상이면 73을 더함(127-> 200, 128->201로 변환하기 위함)
                // 참고 사이트 https://en.wikipedia.org/wiki/Code_128
                if ((intMMM + 32) < 127)
                {
                    strSUM = Char.ToString((char)(intMMM + 32));
                }
                else
                {
                    strSUM = Char.ToString((char)(intMMM + 32 + 73));
                }

                //Console.WriteLine(string.Format("CHECK SUM  :  {0} % {1} = {2}  --> [ {3} ]", intSUM.ToString(), intMOD.ToString(), intMMM.ToString(),strSUM));
                #endregion //체크썸





                #region "START / STOP"

                strrb = string.Format("{0}{1}{2}{3}", Char.ToString((char)intSTA), pstrBARCODE, strSUM, Char.ToString((char)intEND));
                //Console.WriteLine(strrb);

                //strrb = Char.ToString((char)intSTA);
                #endregion //START / STOP


            }
            catch (Exception ex)
            {
                throw ex;
            }
            return strrb;
        }
        #endregion




        #region "CODE39"

        public string CODE39(string pstrBARCODE, ref string pstrERR)
        {
            string strrb = "";

            try
            {
                strrb = "*" + pstrBARCODE + "*";

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return strrb;
        }

        #endregion



        #region "EAN13"


        public string EAN13(string pstrBARCODE, ref string pstrERR)
        {
            string strrb = "";

            try
            {
                string strBAR = "";
                string strTMP = "";
                int intpBARCODE = 0;
                string strBAR1 = "";
                string strBAR2 = "";


                string strFirstNUM = "";
                string strTABLENUM_LST = "";
                string strTABLENUM = "";

                string strSUM = "";
                int intSUMT = 0;
                int intSUM1 = 0; //홀수합계
                int intSUM2 = 0; //짝수합계


                #region "바코드데이터 유효값 확인"
                intpBARCODE = pstrBARCODE.Length;

                if (intpBARCODE < 1) { pstrERR = "데이터영역이 없습니다."; return strrb; }
                if (intpBARCODE < 12) { pstrERR = "12자리 숫자로 입력되어야 합니다"; return strrb; }
                pstrBARCODE = pstrBARCODE.Substring(0, 12);
                intpBARCODE = pstrBARCODE.Length;

                strFirstNUM = pstrBARCODE[0].ToString(); //첫글자추출
                strTABLENUM_LST = lfn_SEQ_TABLE_NUM(strFirstNUM);


                /*
                for (int i = 0; i < intpBARCODE; i++)
                {
                    //Console.WriteLine(pstrBARCODE[i].ToString());
                    if ((pstrBARCODE[i] < 32) || (pstrBARCODE[i] > 126))
                    {
                        pstrERR = "데이터로 쓰지 못하는값이 포함되어있습니다 [ " + pstrBARCODE[i].ToString() + " ]";
                        return strrb;
                    }
                }
                */
                #endregion //바코드데이터 유효값 확인





                #region "바코드값변환"

                strBAR = "";
                intSUM1 = 0;
                intSUM2 = 0;
                for (int i = 0; i < intpBARCODE; i++)
                {
                    strTMP = pstrBARCODE[i].ToString();
                    int intTMP = 0;
                    int.TryParse(strTMP, out intTMP);

                    if (((i + 1) % 2) == 0) //짝수
                    {
                        intSUM2 += intTMP;
                    }
                    else //홀수
                    {
                        intSUM1 += intTMP;
                    }

                    if ((i + 1) == 1)
                    {
                        strBAR += intTMP.ToString();
                    }
                    else if ((i + 1) > 1 && (i + 1) <= 7) //2~7자리 테이블
                    {
                        strTABLENUM = strTABLENUM_LST[i - 1].ToString();
                        strBAR += lfn_TABLE_COD(strTABLENUM, intTMP);
                    }
                    else
                    {
                        strBAR += lfn_TABLE_COD("", intTMP);
                    }
                }

                //공식 : {10 - ( 홀수자리숫자합 + 3 * 짝수자리숫자합) % 10 } % 10
                intSUMT = intSUM1 + (3 * intSUM2);
                intSUMT = 10 - (intSUMT % 10);
                intSUMT = intSUMT % 10;             //체크자리산출
                strSUM = lfn_TABLE_COD("", intSUMT);         //체크자리결과
                strBAR += strSUM;                   //체크자리 추가
                #endregion //체크썸



                #region "START / STOP"
                strBAR1 = strBAR.Substring(0, 7).ToString();
                strBAR2 = strBAR.Substring(7, 6).ToString();



                strrb = string.Format("{0}{1}{2}{3}", strBAR1, "*", strBAR2, "+");
                //Console.WriteLine(strrb);

                //strrb = Char.ToString((char)intSTA);
                #endregion //START / STOP






            }
            catch (Exception ex)
            {
                throw ex;
            }
            return strrb;
        }

        //테이블 참조번호
        private string lfn_SEQ_TABLE_NUM(string pFirstNUM)
        {
            string retb = "";
            try
            {

                switch (pFirstNUM)
                {
                    case "1":
                        retb = "001011";
                        break;
                    case "2":
                        retb = "001101";
                        break;
                    case "3":
                        retb = "001110";
                        break;
                    case "4":
                        retb = "010011";
                        break;
                    case "5":
                        retb = "011001";
                        break;
                    case "6":
                        retb = "011100";
                        break;
                    case "7":
                        retb = "010101";
                        break;
                    case "8":
                        retb = "010110";
                        break;
                    case "9":
                        retb = "011010";
                        break;
                    default: // 0
                        retb = "000000";
                        break;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return retb;
        }


        private string lfn_TABLE_COD(string TABLE_NUM, int VAL)
        {
            string strrb = "";

            #region "0"
            if (TABLE_NUM.Equals("0"))
            {
                switch (VAL)
                {
                    case 0:
                        strrb = "A";
                        break;
                    case 1:
                        strrb = "B";
                        break;
                    case 2:
                        strrb = "C";
                        break;
                    case 3:
                        strrb = "D";
                        break;
                    case 4:
                        strrb = "E";
                        break;
                    case 5:
                        strrb = "F";
                        break;
                    case 6:
                        strrb = "G";
                        break;
                    case 7:
                        strrb = "H";
                        break;
                    case 8:
                        strrb = "I";
                        break;
                    case 9:
                        strrb = "J";
                        break;
                }
            }
            #endregion //0


            #region "1"
            if (TABLE_NUM.Equals("1"))
            {
                switch (VAL)
                {
                    case 0:
                        strrb = "K";
                        break;
                    case 1:
                        strrb = "L";
                        break;
                    case 2:
                        strrb = "M";
                        break;
                    case 3:
                        strrb = "N";
                        break;
                    case 4:
                        strrb = "O";
                        break;
                    case 5:
                        strrb = "P";
                        break;
                    case 6:
                        strrb = "Q";
                        break;
                    case 7:
                        strrb = "R";
                        break;
                    case 8:
                        strrb = "S";
                        break;
                    case 9:
                        strrb = "T";
                        break;
                }
            }
            #endregion //1



            #region "-1"
            if (TABLE_NUM.Equals(""))
            {
                switch (VAL)
                {
                    case 0:
                        strrb = "a";
                        break;
                    case 1:
                        strrb = "b";
                        break;
                    case 2:
                        strrb = "c";
                        break;
                    case 3:
                        strrb = "d";
                        break;
                    case 4:
                        strrb = "e";
                        break;
                    case 5:
                        strrb = "f";
                        break;
                    case 6:
                        strrb = "g";
                        break;
                    case 7:
                        strrb = "h";
                        break;
                    case 8:
                        strrb = "i";
                        break;
                    case 9:
                        strrb = "j";
                        break;
                }
            }
            #endregion //1


            return strrb;
        }


        #endregion //EAN13


    }
}
