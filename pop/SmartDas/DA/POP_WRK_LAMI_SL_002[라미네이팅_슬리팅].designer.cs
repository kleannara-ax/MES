using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK_LAMI_SL_002
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK_LAMI_SL_002));
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            Infragistics.Win.ValueListItem valueListItem14 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem15 = new Infragistics.Win.ValueListItem();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.Grid2 = new SmartDas.Components.MESGrid();
            this.lblINPUT_ORDER_QTY = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.lblINPUT_QTY = new SmartDas.Components.MESLabel();
            this.label12 = new System.Windows.Forms.Label();
            this.lblROLL_QTYSUM = new SmartDas.Components.MESLabel();
            this.label10 = new System.Windows.Forms.Label();
            this.lblROLL_QTY = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.ucPNT_CNT = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.lblPrintChkName = new System.Windows.Forms.Label();
            this.lblPrintChk = new SmartDas.Components.MESLabel();
            this.txtRemark = new System.Windows.Forms.TextBox();
            this.lblMACH_STA = new System.Windows.Forms.Label();
            this.butEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.label34 = new System.Windows.Forms.Label();
            this.dtpStartDate = new System.Windows.Forms.DateTimePicker();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.label20 = new System.Windows.Forms.Label();
            this.lblPRFMMET_QTY = new SmartDas.Components.MESLabel();
            this.lblPF_WGT = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.label18 = new System.Windows.Forms.Label();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.lblUNIT = new SmartDas.Components.MESLabel();
            this.label13 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.lblREMAIN_QTY = new SmartDas.Components.MESLabel();
            this.label7 = new System.Windows.Forms.Label();
            this.lblPRFN_QTY = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.lblINPUTLOTNO = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblORDER_QTY = new SmartDas.Components.MESLabel();
            this.lblPRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.label19 = new System.Windows.Forms.Label();
            this.label15 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.lblINPUTMATNR = new SmartDas.Components.MESLabel();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.dtpEndDate = new System.Windows.Forms.DateTimePicker();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ucPNT_CNT)).BeginInit();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("Malgun Gothic", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // lblMessage
            // 
            this.lblMessage.Position = 183;
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("Malgun Gothic", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 64;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.Grid2);
            this.splitContainer1.Panel1.Controls.Add(this.lblINPUT_ORDER_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.lblINPUT_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.lblROLL_QTYSUM);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblROLL_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.ucPNT_CNT);
            this.splitContainer1.Panel1.Controls.Add(this.lblPrintChkName);
            this.splitContainer1.Panel1.Controls.Add(this.lblPrintChk);
            this.splitContainer1.Panel1.Controls.Add(this.txtRemark);
            this.splitContainer1.Panel1.Controls.Add(this.lblMACH_STA);
            this.splitContainer1.Panel1.Controls.Add(this.butEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.label34);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.label20);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFMMET_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.label18);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.lblUNIT);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.lblREMAIN_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFN_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblINPUTLOTNO);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblORDER_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label19);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblINPUTMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // Grid2
            // 
            this.Grid2.AutoScroll = true;
            this.Grid2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid2.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid2.CountRows = 0;
            this.Grid2.DataSource = null;
            this.Grid2.FixedCols = 0;
            this.Grid2.FontSize = 20.25F;
            this.Grid2.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid2.HeaderFontSize = 13F;
            this.Grid2.HeadString = null;
            this.Grid2.Location = new System.Drawing.Point(843, 341);
            this.Grid2.Name = "Grid2";
            this.Grid2.Row = null;
            this.Grid2.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid2.SelectCommand = null;
            this.Grid2.SelectProcedureName = null;
            this.Grid2.Size = new System.Drawing.Size(410, 129);
            this.Grid2.TabIndex = 356;
            this.Grid2.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid2.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid2_ClickCellButton);
            // 
            // lblINPUT_ORDER_QTY
            // 
            this.lblINPUT_ORDER_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblINPUT_ORDER_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblINPUT_ORDER_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblINPUT_ORDER_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblINPUT_ORDER_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblINPUT_ORDER_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblINPUT_ORDER_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblINPUT_ORDER_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblINPUT_ORDER_QTY.Location = new System.Drawing.Point(1003, 70);
            this.lblINPUT_ORDER_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblINPUT_ORDER_QTY.MoveControl = null;
            this.lblINPUT_ORDER_QTY.Name = "lblINPUT_ORDER_QTY";
            this.lblINPUT_ORDER_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblINPUT_ORDER_QTY.TabIndex = 355;
            this.lblINPUT_ORDER_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblINPUT_ORDER_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Gray;
            this.label8.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(845, 70);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(150, 50);
            this.label8.TabIndex = 354;
            this.label8.Text = "투입지시량";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblINPUT_QTY
            // 
            this.lblINPUT_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblINPUT_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblINPUT_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblINPUT_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblINPUT_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblINPUT_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblINPUT_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblINPUT_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblINPUT_QTY.Location = new System.Drawing.Point(1003, 285);
            this.lblINPUT_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblINPUT_QTY.MoveControl = null;
            this.lblINPUT_QTY.Name = "lblINPUT_QTY";
            this.lblINPUT_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblINPUT_QTY.TabIndex = 353;
            this.lblINPUT_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblINPUT_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Gray;
            this.label12.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(905, 285);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(90, 50);
            this.label12.TabIndex = 352;
            this.label12.Text = "투입량";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblROLL_QTYSUM
            // 
            this.lblROLL_QTYSUM.BackColor = System.Drawing.Color.LightGray;
            this.lblROLL_QTYSUM.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblROLL_QTYSUM.ColorContent = System.Drawing.Color.Transparent;
            this.lblROLL_QTYSUM.ColorLabel = System.Drawing.Color.LightGray;
            this.lblROLL_QTYSUM.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblROLL_QTYSUM.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblROLL_QTYSUM.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblROLL_QTYSUM.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblROLL_QTYSUM.Location = new System.Drawing.Point(1003, 233);
            this.lblROLL_QTYSUM.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblROLL_QTYSUM.MoveControl = null;
            this.lblROLL_QTYSUM.Name = "lblROLL_QTYSUM";
            this.lblROLL_QTYSUM.Size = new System.Drawing.Size(250, 50);
            this.lblROLL_QTYSUM.TabIndex = 353;
            this.lblROLL_QTYSUM.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblROLL_QTYSUM.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(905, 233);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(90, 50);
            this.label10.TabIndex = 352;
            this.label10.Text = "롤수";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblROLL_QTY
            // 
            this.lblROLL_QTY.BackColor = System.Drawing.Color.White;
            this.lblROLL_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblROLL_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblROLL_QTY.ColorLabel = System.Drawing.Color.White;
            this.lblROLL_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblROLL_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblROLL_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblROLL_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblROLL_QTY.Location = new System.Drawing.Point(973, 676);
            this.lblROLL_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblROLL_QTY.MoveControl = null;
            this.lblROLL_QTY.Name = "lblROLL_QTY";
            this.lblROLL_QTY.Size = new System.Drawing.Size(150, 50);
            this.lblROLL_QTY.TabIndex = 351;
            this.lblROLL_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblROLL_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblROLL_QTY.Click += new System.EventHandler(this.lblROLL_QTY_Click);
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Black;
            this.label3.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(845, 676);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(125, 50);
            this.label3.TabIndex = 350;
            this.label3.Text = "롤 수";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ucPNT_CNT
            // 
            appearance1.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            appearance1.TextHAlignAsString = "Center";
            this.ucPNT_CNT.Appearance = appearance1;
            this.ucPNT_CNT.AutoSize = false;
            this.ucPNT_CNT.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPNT_CNT.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucPNT_CNT.Font = new System.Drawing.Font("Malgun Gothic", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            valueListItem14.DataValue = "ValueListItem1";
            valueListItem14.DisplayText = "1 매";
            valueListItem15.DataValue = "ValueListItem2";
            valueListItem15.DisplayText = "2 매";
            this.ucPNT_CNT.Items.AddRange(new Infragistics.Win.ValueListItem[] {
            valueListItem14,
            valueListItem15});
            this.ucPNT_CNT.Location = new System.Drawing.Point(1108, 734);
            this.ucPNT_CNT.Name = "ucPNT_CNT";
            this.ucPNT_CNT.Size = new System.Drawing.Size(150, 46);
            this.ucPNT_CNT.TabIndex = 349;
            // 
            // lblPrintChkName
            // 
            this.lblPrintChkName.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPrintChkName.Location = new System.Drawing.Point(1168, 681);
            this.lblPrintChkName.Name = "lblPrintChkName";
            this.lblPrintChkName.Size = new System.Drawing.Size(88, 40);
            this.lblPrintChkName.TabIndex = 348;
            this.lblPrintChkName.Text = "자동인쇄";
            this.lblPrintChkName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblPrintChk
            // 
            this.lblPrintChk.BackColor = System.Drawing.Color.White;
            this.lblPrintChk.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPrintChk.ColorContent = System.Drawing.Color.Transparent;
            this.lblPrintChk.ColorLabel = System.Drawing.Color.White;
            this.lblPrintChk.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPrintChk.Font = new System.Drawing.Font("Malgun Gothic", 15.75F, System.Drawing.FontStyle.Bold);
            this.lblPrintChk.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPrintChk.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPrintChk.Location = new System.Drawing.Point(1126, 681);
            this.lblPrintChk.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPrintChk.MoveControl = null;
            this.lblPrintChk.Name = "lblPrintChk";
            this.lblPrintChk.Size = new System.Drawing.Size(40, 40);
            this.lblPrintChk.TabIndex = 347;
            this.lblPrintChk.Text = "V";
            this.lblPrintChk.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPrintChk.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPrintChk.Click += new System.EventHandler(this.lblPrintChk_Click);
            // 
            // txtRemark
            // 
            this.txtRemark.Font = new System.Drawing.Font("Malgun Gothic", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtRemark.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtRemark.Location = new System.Drawing.Point(168, 285);
            this.txtRemark.MinimumSize = new System.Drawing.Size(520, 50);
            this.txtRemark.Multiline = true;
            this.txtRemark.Name = "txtRemark";
            this.txtRemark.Size = new System.Drawing.Size(670, 185);
            this.txtRemark.TabIndex = 345;
            // 
            // lblMACH_STA
            // 
            this.lblMACH_STA.BackColor = System.Drawing.Color.Black;
            this.lblMACH_STA.Font = new System.Drawing.Font("Malgun Gothic", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMACH_STA.ForeColor = System.Drawing.Color.Lime;
            this.lblMACH_STA.Location = new System.Drawing.Point(847, 732);
            this.lblMACH_STA.Name = "lblMACH_STA";
            this.lblMACH_STA.Size = new System.Drawing.Size(255, 50);
            this.lblMACH_STA.TabIndex = 343;
            this.lblMACH_STA.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblMACH_STA.Click += new System.EventHandler(this.lblStatus_Click);
            // 
            // butEndDate
            // 
            this.butEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butEndDate.CausesValidation = false;
            this.butEndDate.FlatAppearance.BorderSize = 0;
            this.butEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butEndDate.Font = new System.Drawing.Font("Gulim", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butEndDate.Location = new System.Drawing.Point(635, 678);
            this.butEndDate.Name = "butEndDate";
            this.butEndDate.Size = new System.Drawing.Size(46, 46);
            this.butEndDate.TabIndex = 333;
            this.butEndDate.UseVisualStyleBackColor = false;
            this.butEndDate.Click += new System.EventHandler(this.butEndDate_Click);
            // 
            // butStartDate
            // 
            this.butStartDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDate.CausesValidation = false;
            this.butStartDate.FlatAppearance.BorderSize = 0;
            this.butStartDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDate.Font = new System.Drawing.Font("Gulim", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDate.Location = new System.Drawing.Point(319, 678);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(46, 46);
            this.butStartDate.TabIndex = 332;
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butStartDate_Click);
            // 
            // label34
            // 
            this.label34.AutoSize = true;
            this.label34.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label34.Location = new System.Drawing.Point(466, 687);
            this.label34.Name = "label34";
            this.label34.Size = new System.Drawing.Size(25, 25);
            this.label34.TabIndex = 331;
            this.label34.Text = "~";
            // 
            // dtpStartDate
            // 
            this.dtpStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDate.Enabled = false;
            this.dtpStartDate.Font = new System.Drawing.Font("Malgun Gothic", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDate.Location = new System.Drawing.Point(177, 676);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(190, 50);
            this.dtpStartDate.TabIndex = 330;
            // 
            // lblEndTime
            // 
            this.lblEndTime.BackColor = System.Drawing.Color.White;
            this.lblEndTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEndTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblEndTime.ColorLabel = System.Drawing.Color.White;
            this.lblEndTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEndTime.Font = new System.Drawing.Font("Malgun Gothic", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEndTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEndTime.Location = new System.Drawing.Point(687, 676);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(90, 50);
            this.lblEndTime.TabIndex = 329;
            this.lblEndTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblEndTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label20
            // 
            this.label20.BackColor = System.Drawing.Color.Black;
            this.label20.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label20.ForeColor = System.Drawing.Color.White;
            this.label20.Location = new System.Drawing.Point(427, 731);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(165, 50);
            this.label20.TabIndex = 321;
            this.label20.Text = "실적(M)";
            this.label20.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFMMET_QTY
            // 
            this.lblPRFMMET_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFMMET_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFMMET_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFMMET_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFMMET_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFMMET_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFMMET_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFMMET_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFMMET_QTY.Location = new System.Drawing.Point(599, 731);
            this.lblPRFMMET_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFMMET_QTY.MoveControl = null;
            this.lblPRFMMET_QTY.Name = "lblPRFMMET_QTY";
            this.lblPRFMMET_QTY.Size = new System.Drawing.Size(240, 50);
            this.lblPRFMMET_QTY.TabIndex = 322;
            this.lblPRFMMET_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFMMET_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPF_WGT
            // 
            this.lblPF_WGT.BackColor = System.Drawing.Color.White;
            this.lblPF_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_WGT.ColorLabel = System.Drawing.Color.White;
            this.lblPF_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_WGT.Font = new System.Drawing.Font("Malgun Gothic", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_WGT.Location = new System.Drawing.Point(179, 732);
            this.lblPF_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_WGT.MoveControl = null;
            this.lblPF_WGT.Name = "lblPF_WGT";
            this.lblPF_WGT.Size = new System.Drawing.Size(240, 50);
            this.lblPF_WGT.TabIndex = 320;
            this.lblPF_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPF_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPF_WGT.Click += new System.EventHandler(this.lblPF_WGT_Click);
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Black;
            this.label14.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(7, 732);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(165, 50);
            this.label14.TabIndex = 316;
            this.label14.Text = "중량(kg)";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label18
            // 
            this.label18.BackColor = System.Drawing.Color.Black;
            this.label18.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label18.ForeColor = System.Drawing.Color.White;
            this.label18.Location = new System.Drawing.Point(6, 676);
            this.label18.Name = "label18";
            this.label18.Size = new System.Drawing.Size(165, 50);
            this.label18.TabIndex = 314;
            this.label18.Text = "작업일시";
            this.label18.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblStartTime
            // 
            this.lblStartTime.BackColor = System.Drawing.Color.White;
            this.lblStartTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTime.ColorLabel = System.Drawing.Color.White;
            this.lblStartTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTime.Font = new System.Drawing.Font("Malgun Gothic", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTime.Location = new System.Drawing.Point(371, 676);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(90, 50);
            this.lblStartTime.TabIndex = 315;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // lblUNIT
            // 
            this.lblUNIT.BackColor = System.Drawing.Color.LightGray;
            this.lblUNIT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblUNIT.ColorContent = System.Drawing.Color.Transparent;
            this.lblUNIT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblUNIT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblUNIT.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblUNIT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblUNIT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblUNIT.Location = new System.Drawing.Point(1163, 15);
            this.lblUNIT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblUNIT.MoveControl = null;
            this.lblUNIT.Name = "lblUNIT";
            this.lblUNIT.Size = new System.Drawing.Size(90, 50);
            this.lblUNIT.TabIndex = 231;
            this.lblUNIT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblUNIT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(845, 125);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(55, 210);
            this.label13.TabIndex = 225;
            this.label13.Text = "실 적 량";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(905, 180);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(90, 50);
            this.label9.TabIndex = 160;
            this.label9.Text = "잔량";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblREMAIN_QTY
            // 
            this.lblREMAIN_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblREMAIN_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblREMAIN_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblREMAIN_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblREMAIN_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblREMAIN_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblREMAIN_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblREMAIN_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblREMAIN_QTY.Location = new System.Drawing.Point(1003, 180);
            this.lblREMAIN_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblREMAIN_QTY.MoveControl = null;
            this.lblREMAIN_QTY.Name = "lblREMAIN_QTY";
            this.lblREMAIN_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblREMAIN_QTY.TabIndex = 161;
            this.lblREMAIN_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblREMAIN_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(905, 125);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(90, 50);
            this.label7.TabIndex = 156;
            this.label7.Text = "중량";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFN_QTY
            // 
            this.lblPRFN_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFN_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFN_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFN_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFN_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFN_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFN_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFN_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFN_QTY.Location = new System.Drawing.Point(1003, 125);
            this.lblPRFN_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFN_QTY.MoveControl = null;
            this.lblPRFN_QTY.Name = "lblPRFN_QTY";
            this.lblPRFN_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblPRFN_QTY.TabIndex = 157;
            this.lblPRFN_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFN_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(13, 285);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(150, 185);
            this.label6.TabIndex = 154;
            this.label6.Text = "비고";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(13, 70);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(150, 50);
            this.label5.TabIndex = 152;
            this.label5.Text = "작업지시번호";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblINPUTLOTNO
            // 
            this.lblINPUTLOTNO.BackColor = System.Drawing.Color.LightGray;
            this.lblINPUTLOTNO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblINPUTLOTNO.ColorContent = System.Drawing.Color.Transparent;
            this.lblINPUTLOTNO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblINPUTLOTNO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblINPUTLOTNO.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblINPUTLOTNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblINPUTLOTNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblINPUTLOTNO.Location = new System.Drawing.Point(170, 233);
            this.lblINPUTLOTNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblINPUTLOTNO.MoveControl = null;
            this.lblINPUTLOTNO.Name = "lblINPUTLOTNO";
            this.lblINPUTLOTNO.Size = new System.Drawing.Size(670, 50);
            this.lblINPUTLOTNO.TabIndex = 153;
            this.lblINPUTLOTNO.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblINPUTLOTNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWRK_ORDR_NO
            // 
            this.lblWRK_ORDR_NO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(169, 70);
            this.lblWRK_ORDR_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_NO.MoveControl = null;
            this.lblWRK_ORDR_NO.Name = "lblWRK_ORDR_NO";
            this.lblWRK_ORDR_NO.Size = new System.Drawing.Size(480, 50);
            this.lblWRK_ORDR_NO.TabIndex = 153;
            this.lblWRK_ORDR_NO.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(845, 15);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(150, 50);
            this.label4.TabIndex = 150;
            this.label4.Text = "계획량";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblORDER_QTY
            // 
            this.lblORDER_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblORDER_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblORDER_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblORDER_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblORDER_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblORDER_QTY.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblORDER_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblORDER_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblORDER_QTY.Location = new System.Drawing.Point(1003, 15);
            this.lblORDER_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblORDER_QTY.MoveControl = null;
            this.lblORDER_QTY.Name = "lblORDER_QTY";
            this.lblORDER_QTY.Size = new System.Drawing.Size(160, 50);
            this.lblORDER_QTY.TabIndex = 151;
            this.lblORDER_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblORDER_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPRD_REQ_DT
            // 
            this.lblPRD_REQ_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_REQ_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DT.Location = new System.Drawing.Point(169, 15);
            this.lblPRD_REQ_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DT.MoveControl = null;
            this.lblPRD_REQ_DT.Name = "lblPRD_REQ_DT";
            this.lblPRD_REQ_DT.Size = new System.Drawing.Size(670, 50);
            this.lblPRD_REQ_DT.TabIndex = 149;
            this.lblPRD_REQ_DT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRD_REQ_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWRK_ORDR_SEQNO
            // 
            this.lblWRK_ORDR_SEQNO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_SEQNO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_SEQNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_SEQNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(659, 70);
            this.lblWRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO.MoveControl = null;
            this.lblWRK_ORDR_SEQNO.Name = "lblWRK_ORDR_SEQNO";
            this.lblWRK_ORDR_SEQNO.Size = new System.Drawing.Size(180, 50);
            this.lblWRK_ORDR_SEQNO.TabIndex = 148;
            this.lblWRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(13, 15);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 142;
            this.label2.Text = "생산요청일";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label19
            // 
            this.label19.BackColor = System.Drawing.Color.Gray;
            this.label19.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label19.ForeColor = System.Drawing.Color.White;
            this.label19.Location = new System.Drawing.Point(13, 233);
            this.label19.Name = "label19";
            this.label19.Size = new System.Drawing.Size(150, 50);
            this.label19.TabIndex = 143;
            this.label19.Text = "투입 LOT.NO";
            this.label19.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Gray;
            this.label15.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(13, 180);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(150, 50);
            this.label15.TabIndex = 143;
            this.label15.Text = "투입품목";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(13, 125);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 143;
            this.label1.Text = "품목";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblINPUTMATNR
            // 
            this.lblINPUTMATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblINPUTMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblINPUTMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblINPUTMATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblINPUTMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblINPUTMATNR.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblINPUTMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblINPUTMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblINPUTMATNR.Location = new System.Drawing.Point(169, 180);
            this.lblINPUTMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblINPUTMATNR.MoveControl = null;
            this.lblINPUTMATNR.Name = "lblINPUTMATNR";
            this.lblINPUTMATNR.Size = new System.Drawing.Size(670, 50);
            this.lblINPUTMATNR.TabIndex = 144;
            this.lblINPUTMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblINPUTMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(169, 125);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(670, 50);
            this.lblMATNR.TabIndex = 144;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // Grid1
            // 
            this.Grid1.AutoScroll = true;
            this.Grid1.BackColor = System.Drawing.Color.Transparent;
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(8, 476);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 190);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Enabled = false;
            this.dtpEndDate.Font = new System.Drawing.Font("Malgun Gothic", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(492, 676);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(190, 50);
            this.dtpEndDate.TabIndex = 342;
            // 
            // timer1
            // 
            this.timer1.Interval = 1000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // POP_WRK_LAMI_SL_002
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK_LAMI_SL_002";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK_LAMI_SL_002_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.ucPNT_CNT)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWRK_ORDR_NO;
        private System.Windows.Forms.Label label4;
        private MESLabel lblORDER_QTY;
        private MESLabel lblPRD_REQ_DT;
        private MESLabel lblWRK_ORDR_SEQNO;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private MESLabel lblMATNR;
        private System.Windows.Forms.Label label9;
        private MESLabel lblREMAIN_QTY;
        private System.Windows.Forms.Label label7;
        private MESLabel lblPRFN_QTY;
        private System.Windows.Forms.Label label13;
        private MESLabel lblUNIT;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Button butEndDate;
        private System.Windows.Forms.Button butStartDate;
        private System.Windows.Forms.Label label34;
        private System.Windows.Forms.DateTimePicker dtpStartDate;
        private MESLabel lblEndTime;
        private System.Windows.Forms.Label label20;
        private MESLabel lblPRFMMET_QTY;
        private MESLabel lblPF_WGT;
        private System.Windows.Forms.Label label14;
        private System.Windows.Forms.Label label18;
        private MESLabel lblStartTime;
        private System.Windows.Forms.DateTimePicker dtpEndDate;
        private System.Windows.Forms.Label lblMACH_STA;
        private System.Windows.Forms.TextBox txtRemark;
        private System.Windows.Forms.Label lblPrintChkName;
        private MESLabel lblPrintChk;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucPNT_CNT;
        private MESLabel lblROLL_QTY;
        private System.Windows.Forms.Label label3;
        private MESLabel lblROLL_QTYSUM;
        private System.Windows.Forms.Label label10;
        private MESLabel lblINPUTLOTNO;
        private System.Windows.Forms.Label label19;
        private System.Windows.Forms.Label label15;
        private MESLabel lblINPUTMATNR;
        private MESLabel lblINPUT_QTY;
        private System.Windows.Forms.Label label12;
        private MESLabel lblINPUT_ORDER_QTY;
        private System.Windows.Forms.Label label8;
        private MESGrid Grid2;

    }
}
