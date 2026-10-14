using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using System.Runtime.InteropServices;
using Infragistics.Win.Misc;
using System.Collections;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System.Data.SqlClient;
using SAMMI;
using Infragistics.Win.UltraWinGrid;

namespace SmartDas.POPUP
{
    public partial class POP_WRK80 : Form
    {
        private string gsMachType = ""; // 공정 타입
        private string gsPlantCode = "";
        //private string gsLineCode = "";

        private string resultMATNR = "";
        private string resultMATNR_NM = "";
        private string resultPCODE_NM = "";

        private string resultBS_WGT = "";

        public double ResultDoubleBS_WGT = 0;
        public double ResultDoubleWLEN = 0;
        public double ResultDoubleVLEN = 0;

        public string ResultMATNR
        {
            get
            {
                return resultMATNR;
            }
        }

        public string ResultMATNR_NM
        {
            get
            {
                return resultMATNR_NM;
            }
        }

        public string ResultPCODE_NM
        {
            get
            {
                return resultPCODE_NM;
            }
        }
        
        public string ResultBS_WGT
        {
            get
            {
                return resultBS_WGT;
            }
        }

        public POP_WRK80(string sMATNR)
        {
            string sLineCode = "";

            InitializeComponent();

            
            gsPlantCode = Common.PlantCode;

            gsMachType = Common.OpCode;

            ucMachineLine.Location = lblMachineLine.Location;

            if (Common.OpCode == "JA")
            {
                // 점보롤인경우는 설비호기 코드 참고
                sLineCode = Common.MachineNo.Replace("PM", "H");  // 라인코드 는 2호기는=H2, 3호기는=H3 로 사용하기위해서 설비호기명으로 REPLACE 처리하여 사용
                lblMachineLine.Text = Common.MachineNo.Replace("PM", "") + "호기";

                panelWidthLength.Visible = false;
                lblMachineLine.Visible = true;
                //ucMachineLine.Visible = true;
            }
            else
            {
                // 포장인경우는 자재코드 앞2자리 참고
                if (!string.IsNullOrEmpty(sMATNR))
                {
                    sLineCode = sMATNR.Substring(0, 2);
                }
                else
                {
                    // 자재코드 정보가 없는경우 예외처리
                    sLineCode = Common.MachineNo.Replace("PM", "F");  // 라인코드 는 2호기는=F2, 3호기는=F3 로 사용하기위해서 설비호기명으로 REPLACE 처리하여 사용
                }

                //ucMachineLine.Text = Common.MachineNo.Replace("PM", "") + "호기";
                ucMachineLine.Visible = true;
            }

            if (sLineCode == "F2" || sLineCode == "H2")
            {
                ucMachineLine.SelectedIndex = 0;
            }
            else
            {
                ucMachineLine.SelectedIndex = 1;
            }

            ucMachineLine.ValueList.ItemHeight = 70;
        }

        private void POP_WRK80_Load(object sender, EventArgs e)
        {

        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void lblPType_Click(object sender, EventArgs e)
        {
            DA9200 pop = new DA9200();
            pop.LabelHeader = "지종 입력";
            pop.ContentMaxLength = 3;
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPCode.Text = pop.ResultString.ToUpper();

                //if ( lblPCode.Text.Length > 0 && lblWeight.Text.Length > 0)
                //{
                //    SetGrid();
                //}
            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            if (lblPCode.Text.Length == 0)
            {
                new POPUP.MessageForm("지종코드 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            else if (lblWeight.Text.Length == 0)
            {
                new POPUP.MessageForm("평량값 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            else
            {
                SetGrid();
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;
            
            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            string sProdureName = string.Empty;
            try
            {
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 6;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Vertical;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                string sLineCode = "";
                // 점보롤 : SP_POP_WRK80_S01
                // 포장   : SP_POP_WRK80_S02

                //버튼 목록 조회
                if (gsMachType == "JA")
                {
                    sProdureName = "SP_POP_WRK80_S01";
                    sLineCode = "H" + ucMachineLine.SelectedItem.Tag;    // 반제품 코드
                }
                else
                {
                    sProdureName = "SP_POP_WRK80_S02";
                    sLineCode = "F" + ucMachineLine.SelectedItem.Tag;    // 완제품 코드
                }

                this.Cursor = Cursors.WaitCursor;   //Waitting

                dtRtn = helper.FillTable(sProdureName, CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", gsPlantCode, DbType.String, ParameterDirection.Input)                   // 플랜트코드
                                                    , helper.CreateParameter("P_LINE", sLineCode, DbType.String, ParameterDirection.Input)                     // 호기 (H2=2호기, H3=3호기)
                                                    , helper.CreateParameter("P_PCODE", lblPCode.Text.ToString(), DbType.String, ParameterDirection.Input)      // 지종코드
                                                    , helper.CreateParameter("P_WEIGHT", lblWeight.Text.ToString(), DbType.String, ParameterDirection.Input)    // 평량(3자리)
                                                    , helper.CreateParameter("P_WIDTH", lblWidth.Text.ToString(), DbType.String, ParameterDirection.Input)      // 가로(4자리)
                                                    , helper.CreateParameter("P_LENGTH", lblLength.Text.ToString(), DbType.String, ParameterDirection.Input)    // 세로(4자리)
                                                    , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                    , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 자재코드가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    //컬럼설정 정보
                    sColInfo = helper.Parameters["P_COLINFO"].Value.ToString();
                    sColType = helper.Parameters["P_COLTYPE"].Value.ToString();
                    //컬럼 설정 테이블 생성
                    dtTemp.Columns.Add(new DataColumn("colInfo", typeof(string)));
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColInfo;
                    dtTemp.Rows.Add(rTemp);
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColType;
                    dtTemp.Rows.Add(rTemp);
                    //컬럼설정 및 데이터 목록 작성
                    dsTemp.Tables.Add(dtTemp);
                    dsTemp.Tables.Add(dtRtn);
                    //그리드 출력
                    Grid1.DoFind_Oracle(dsTemp);

                    // 첫번째 행 선택
                    Grid1.Rows[0].Selected = true;
                    Grid1.Row = Grid1.Rows[0];

                    resultMATNR = Grid1.Row.Cells["MATNR"].Value.ToString();
                    resultMATNR_NM = Grid1.Row.Cells["MATNR_NM"].Value.ToString();
                    resultPCODE_NM = Grid1.Row.Cells["PCODE_NM"].Value.ToString();

                    double.TryParse(Grid1.Row.Cells["BS_WGT"].Value.ToString().Replace(",", ""), out ResultDoubleBS_WGT);             // 평량
                    double.TryParse(Grid1.Row.Cells["WLEN"].Value.ToString().Replace(",", ""), out ResultDoubleWLEN);               // 가로길이
                    double.TryParse(Grid1.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out ResultDoubleVLEN);               // 세로길이

                    resultBS_WGT = Grid1.Row.Cells["BS_WGT"].Value.ToString();

                    lblMATNR.Text = resultMATNR;
                }

            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting

                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.SetGrid Error => " + ex.Message);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
            }

        }

        private void Grid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            //조회된 항목이 없는 경우 처리
            if (Grid1.Rows.Count < 1)
                return;
            if (Grid1.Row == null)
                return;

            //클릭된 행
            resultMATNR = Grid1.Row.Cells["MATNR"].Value.ToString();
            resultMATNR_NM = Grid1.Row.Cells["MATNR_NM"].Value.ToString();

            resultPCODE_NM = Grid1.Row.Cells["PCODE_NM"].Value.ToString();
            double.TryParse(Grid1.Row.Cells["BS_WGT"].Value.ToString().Replace(",", ""), out ResultDoubleBS_WGT);             // 평량
            double.TryParse(Grid1.Row.Cells["WLEN"].Value.ToString().Replace(",", ""), out ResultDoubleWLEN);               // 가로길이
            double.TryParse(Grid1.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out ResultDoubleVLEN);               // 세로길이

            resultBS_WGT = Grid1.Row.Cells["BS_WGT"].Value.ToString();

            lblMATNR.Text = resultMATNR;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (resultMATNR == "")
            {
                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                return;
            }
            else
            {
                //resultBS_WGT = lblWeight.Text.ToString();

                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void lblWeight_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "평량 입력";
            pop.LabelHeader = "평량(g/m²)";
            //pop.LabelHeader = "평량(g/㎡)";
            pop.ContentMaxLength = 3;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblWeight.Text = pop.ResultString;

                //if (lblPCode.Text.Length > 0 && lblWeight.Text.Length > 0)
                //{
                //    SetGrid();
                //}
            }
        }

        private void lblWidth_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "가로 입력";
            pop.LabelHeader = "가로 길이";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblWidth.Text = pop.ResultString;

                if (lblPCode.Text.Length > 0 && lblWeight.Text.Length > 0)
                {
                    SetGrid();
                }
            }
        }

        private void lblLength_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "세로 입력";
            pop.LabelHeader = "세로 길이";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblLength.Text = pop.ResultString;

                if (lblPCode.Text.Length > 0 && lblWeight.Text.Length > 0)
                {
                    SetGrid();
                }
            }
        }
    }
}
