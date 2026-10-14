using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace SAP_STOCK
{
    public partial class Form1 : Form
    {
        DataTable dtList = new DataTable();

        public Form1()
        {
            InitializeComponent();
        }

        //SAP Connect
        public void SearchSAP()
        {
            SAPHelper SAPTemp = new SAPHelper();

            if (SAPTemp.GetStckData(txtWERKS.Text, txtLOTNO.Text, txtMATNR.Text, txtLOCA.Text).Equals("S"))
            {
                grdRtn.DataSource = SAPTemp.rtnTable;

                if (SAPTemp.rtnTable.Rows.Count == 0)
                {
                    MessageBox.Show("정보 없음");
                }
            }
            else
            {
                MessageBox.Show(SAPTemp.rtnMSG);
            }

        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            string sWERKS = txtWERKS.Text.ToString();
            if (sWERKS == "")
            {
                MessageBox.Show("WERKS는 필수 입력 입니다.");
                return;
            }

            string sLOTNO = txtLOTNO.Text.ToString();
            string sMATNR = txtMATNR.Text.ToString();
            string sLOCA = txtLOCA.Text.ToString();
            if (sLOTNO == "" && sMATNR == "" && sLOCA == "")
            {
                MessageBox.Show("조회 조건 입력 하세요");
                return;
            }


            SearchSAP();
        }

        private void btnClean_Click(object sender, EventArgs e)
        {
            txtLOTNO.Text = txtMATNR.Text = txtLOCA.Text = string.Empty;
            grdRtn.DataSource = null;
        }


        public void CreateFileHeader()
        {
             string sData = string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}\r\n",
                                "WERKS",
                                "IND_BCD",
                                "MATNR",
                                "LOTNO",
                                "WERKS",
                                "LGORT",
                                "MATNR",
                                "CHARG",
                                "SOBKZ",
                                "KDAUF",
                                "KDPOS",
                                "KUNNR",
                                "LIFNR",
                                "STQTY",
                                "SPEME",
                                "MEINS");

            using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"d:\KNARA\stock_001.csv", append: false))
            {
                file.Write(sData);
            }
        }

        //SAP Connect
        public void FileSearchSAP(string sWERKS, string sIND_BCD, string sLOTNO, string sMATNR, string sLOCA)
        {
            SAPHelper SAPTemp = new SAPHelper();

            string sData = "";

            if (SAPTemp.GetStckData(sWERKS, sLOTNO, sMATNR, sLOCA).Equals("S"))
            {
                if (SAPTemp.rtnTable.Rows.Count > 0)
                {
                    foreach (DataRow row in SAPTemp.rtnTable.Rows)
                    {
                        sData = string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                                            sWERKS,
                                            sIND_BCD,
                                            sMATNR,
                                            sLOTNO,
                                            row["WERKS"].ToString(),
                                            row["LGORT"].ToString(),
                                            row["MATNR"].ToString(),
                                            row["CHARG"].ToString(),
                                            row["SOBKZ"].ToString(),
                                            row["KDAUF"].ToString(),
                                            row["KDPOS"].ToString(),
                                            row["KUNNR"].ToString(),
                                            row["LIFNR"].ToString(),
                                            row["STQTY"].ToString(),
                                            row["SPEME"].ToString(),
                                            row["MEINS"].ToString());

                        using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"d:\KNARA\stock_001.csv", append: true))
                        {
                            file.WriteLine(sData);
                        }

                    }
                }
                else
                {
                    sData = string.Format("{0},{1},{2},{3},,,,,,,,,0,0,",
                                        sWERKS,
                                        sIND_BCD,
                                        sMATNR,
                                        sLOTNO,
                                        "not find");

                    using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"d:\KNARA\stock_001.csv", append: true))
                    {
                        file.WriteLine(sData);
                    }

                }


                //if (SAPTemp.rtnTable.Rows.Count == 0)
                //{
                //    MessageBox.Show("정보 없음");
                //}
            }
            else
            {
                sData = string.Format("{0},{1},{2},{3},,,,,,,,,0,0,",
                                sWERKS,
                                    sMATNR,
                                    sLOTNO,
                                    SAPTemp.rtnMSG);
            }


        }


        private void btnFileFind_Click(object sender, EventArgs e)
        {
            StreamReader sr = new StreamReader("D:\\KNARA\\STOCK.TXT");

            CreateFileHeader();
            while (sr.Peek() >= 0)
            {
                // 1. 첫 라인을 읽어서 문자열로 변환
                String s = sr.ReadLine().ToString();

                // " " 기준으로 문자열 분리
                // String[] s2 = s.Split(", ", StringSplitOptions.None);
                String[] s2 = s.Split(',');


                Console.WriteLine(s);

                string sWERKS = s2[0].Trim();
                string sIND_BCD = s2[1].Trim();
                string sMATNR = s2[2].Trim();
                string sLOTNO = s2[3].Trim();
                string sLOCA = s2[4].Trim();
                //if (sLOTNO == "" && sMATNR == "" && sWERKS == "")
                //{
                //    MessageBox.Show("조회 조건 입력 하세요");
                //    return;
                //}

                FileSearchSAP(sWERKS, sIND_BCD, sLOTNO, sMATNR, sLOCA);
            }
            sr.Close();


            MessageBox.Show("완료");
        }
    }
}
