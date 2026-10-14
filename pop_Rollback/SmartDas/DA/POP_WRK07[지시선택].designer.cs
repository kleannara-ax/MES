using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK07
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK07));
            this.lblREQ_DATE = new System.Windows.Forms.Label();
            this.lblMATNR = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblRemark = new SmartDas.Components.MESLabel();
            this.txtVLEN = new System.Windows.Forms.TextBox();
            this.txtWLEN = new System.Windows.Forms.TextBox();
            this.lblWV = new System.Windows.Forms.Label();
            this.btnREQ_END_DATE = new System.Windows.Forms.Button();
            this.btnREQ_STR_DATE = new System.Windows.Forms.Button();
            this.txtWEIGHT = new System.Windows.Forms.TextBox();
            this.txtPCODE = new System.Windows.Forms.TextBox();
            this.txtMATNR = new System.Windows.Forms.TextBox();
            this.lblPW = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.dtpREQ_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.dtpREQ_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.pnlORDER_LOT = new System.Windows.Forms.Panel();
            this.txtORDER_NO = new System.Windows.Forms.TextBox();
            this.lblLOT_NO = new System.Windows.Forms.Label();
            this.txtLOT_NO = new System.Windows.Forms.TextBox();
            this.lblORDER_NO = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.pnlORDER_LOT.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // lblREQ_DATE
            // 
            this.lblREQ_DATE.BackColor = System.Drawing.Color.Gray;
            this.lblREQ_DATE.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblREQ_DATE.ForeColor = System.Drawing.Color.White;
            this.lblREQ_DATE.Location = new System.Drawing.Point(9, 11);
            this.lblREQ_DATE.Name = "lblREQ_DATE";
            this.lblREQ_DATE.Size = new System.Drawing.Size(106, 32);
            this.lblREQ_DATE.TabIndex = 49;
            this.lblREQ_DATE.Text = "생산요청일";
            this.lblREQ_DATE.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.Gray;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.ForeColor = System.Drawing.Color.White;
            this.lblMATNR.Location = new System.Drawing.Point(9, 52);
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(106, 32);
            this.lblMATNR.TabIndex = 51;
            this.lblMATNR.Text = "자재 코드";
            this.lblMATNR.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
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
            this.bBox1.TabStop = false;
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
            this.splitContainer1.Panel1.Controls.Add(this.lblRemark);
            this.splitContainer1.Panel1.Controls.Add(this.txtVLEN);
            this.splitContainer1.Panel1.Controls.Add(this.txtWLEN);
            this.splitContainer1.Panel1.Controls.Add(this.lblWV);
            this.splitContainer1.Panel1.Controls.Add(this.btnREQ_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnREQ_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.txtWEIGHT);
            this.splitContainer1.Panel1.Controls.Add(this.txtPCODE);
            this.splitContainer1.Panel1.Controls.Add(this.txtMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.lblPW);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.dtpREQ_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.dtpREQ_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.lblREQ_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.pnlORDER_LOT);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblRemark
            // 
            this.lblRemark.BackColor = System.Drawing.Color.White;
            this.lblRemark.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblRemark.ColorContent = System.Drawing.Color.Transparent;
            this.lblRemark.ColorLabel = System.Drawing.Color.White;
            this.lblRemark.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblRemark.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblRemark.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblRemark.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblRemark.Location = new System.Drawing.Point(11, 633);
            this.lblRemark.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblRemark.MoveControl = null;
            this.lblRemark.Name = "lblRemark";
            this.lblRemark.Size = new System.Drawing.Size(1250, 150);
            this.lblRemark.TabIndex = 126;
            this.lblRemark.TabStop = false;
            this.lblRemark.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblRemark.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblRemark.Visible = false;
            // 
            // txtVLEN
            // 
            this.txtVLEN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtVLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtVLEN.Location = new System.Drawing.Point(989, 52);
            this.txtVLEN.MaxLength = 5;
            this.txtVLEN.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtVLEN.Name = "txtVLEN";
            this.txtVLEN.Size = new System.Drawing.Size(100, 32);
            this.txtVLEN.TabIndex = 7;
            this.txtVLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtVLEN.Visible = false;
            // 
            // txtWLEN
            // 
            this.txtWLEN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtWLEN.Location = new System.Drawing.Point(883, 52);
            this.txtWLEN.MaxLength = 5;
            this.txtWLEN.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtWLEN.Name = "txtWLEN";
            this.txtWLEN.Size = new System.Drawing.Size(100, 32);
            this.txtWLEN.TabIndex = 6;
            this.txtWLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtWLEN.Visible = false;
            // 
            // lblWV
            // 
            this.lblWV.BackColor = System.Drawing.Color.Gray;
            this.lblWV.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWV.ForeColor = System.Drawing.Color.White;
            this.lblWV.Location = new System.Drawing.Point(771, 52);
            this.lblWV.Name = "lblWV";
            this.lblWV.Size = new System.Drawing.Size(106, 32);
            this.lblWV.TabIndex = 230;
            this.lblWV.Text = "가로/세로";
            this.lblWV.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblWV.Visible = false;
            // 
            // btnREQ_END_DATE
            // 
            this.btnREQ_END_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnREQ_END_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnREQ_END_DATE.CausesValidation = false;
            this.btnREQ_END_DATE.FlatAppearance.BorderSize = 0;
            this.btnREQ_END_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnREQ_END_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnREQ_END_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnREQ_END_DATE.Location = new System.Drawing.Point(411, 13);
            this.btnREQ_END_DATE.Name = "btnREQ_END_DATE";
            this.btnREQ_END_DATE.Size = new System.Drawing.Size(28, 28);
            this.btnREQ_END_DATE.TabIndex = 229;
            this.btnREQ_END_DATE.TabStop = false;
            this.btnREQ_END_DATE.Tag = "endDate";
            this.btnREQ_END_DATE.UseVisualStyleBackColor = false;
            this.btnREQ_END_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // btnREQ_STR_DATE
            // 
            this.btnREQ_STR_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnREQ_STR_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnREQ_STR_DATE.CausesValidation = false;
            this.btnREQ_STR_DATE.FlatAppearance.BorderSize = 0;
            this.btnREQ_STR_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnREQ_STR_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnREQ_STR_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnREQ_STR_DATE.Location = new System.Drawing.Point(234, 13);
            this.btnREQ_STR_DATE.Name = "btnREQ_STR_DATE";
            this.btnREQ_STR_DATE.Size = new System.Drawing.Size(28, 28);
            this.btnREQ_STR_DATE.TabIndex = 228;
            this.btnREQ_STR_DATE.TabStop = false;
            this.btnREQ_STR_DATE.Tag = "startDate";
            this.btnREQ_STR_DATE.UseVisualStyleBackColor = false;
            this.btnREQ_STR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // txtWEIGHT
            // 
            this.txtWEIGHT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWEIGHT.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtWEIGHT.Location = new System.Drawing.Point(989, 11);
            this.txtWEIGHT.MaxLength = 4;
            this.txtWEIGHT.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtWEIGHT.Name = "txtWEIGHT";
            this.txtWEIGHT.Size = new System.Drawing.Size(100, 32);
            this.txtWEIGHT.TabIndex = 5;
            this.txtWEIGHT.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtWEIGHT.Visible = false;
            // 
            // txtPCODE
            // 
            this.txtPCODE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPCODE.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtPCODE.Location = new System.Drawing.Point(883, 11);
            this.txtPCODE.MaxLength = 3;
            this.txtPCODE.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtPCODE.Name = "txtPCODE";
            this.txtPCODE.Size = new System.Drawing.Size(100, 32);
            this.txtPCODE.TabIndex = 4;
            this.txtPCODE.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtPCODE.Visible = false;
            // 
            // txtMATNR
            // 
            this.txtMATNR.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMATNR.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtMATNR.Location = new System.Drawing.Point(121, 52);
            this.txtMATNR.MaxLength = 20;
            this.txtMATNR.MinimumSize = new System.Drawing.Size(0, 32);
            this.txtMATNR.Name = "txtMATNR";
            this.txtMATNR.Size = new System.Drawing.Size(320, 32);
            this.txtMATNR.TabIndex = 1;
            // 
            // lblPW
            // 
            this.lblPW.BackColor = System.Drawing.Color.Gray;
            this.lblPW.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPW.ForeColor = System.Drawing.Color.White;
            this.lblPW.Location = new System.Drawing.Point(771, 11);
            this.lblPW.Name = "lblPW";
            this.lblPW.Size = new System.Drawing.Size(106, 32);
            this.lblPW.TabIndex = 137;
            this.lblPW.Text = "지종/평량";
            this.lblPW.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblPW.Visible = false;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.Location = new System.Drawing.Point(266, 9);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(32, 32);
            this.label4.TabIndex = 136;
            this.label4.Text = "~";
            // 
            // dtpREQ_END_DATE
            // 
            this.dtpREQ_END_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpREQ_END_DATE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpREQ_END_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpREQ_END_DATE.Location = new System.Drawing.Point(299, 11);
            this.dtpREQ_END_DATE.MinimumSize = new System.Drawing.Size(0, 32);
            this.dtpREQ_END_DATE.Name = "dtpREQ_END_DATE";
            this.dtpREQ_END_DATE.ShowUpDown = true;
            this.dtpREQ_END_DATE.Size = new System.Drawing.Size(142, 32);
            this.dtpREQ_END_DATE.TabIndex = 133;
            this.dtpREQ_END_DATE.TabStop = false;
            this.dtpREQ_END_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // dtpREQ_STR_DATE
            // 
            this.dtpREQ_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpREQ_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpREQ_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpREQ_STR_DATE.Location = new System.Drawing.Point(121, 11);
            this.dtpREQ_STR_DATE.MinimumSize = new System.Drawing.Size(0, 32);
            this.dtpREQ_STR_DATE.Name = "dtpREQ_STR_DATE";
            this.dtpREQ_STR_DATE.ShowUpDown = true;
            this.dtpREQ_STR_DATE.Size = new System.Drawing.Size(142, 32);
            this.dtpREQ_STR_DATE.TabIndex = 124;
            this.dtpREQ_STR_DATE.TabStop = false;
            this.dtpREQ_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // btnFind
            // 
            this.btnFind.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnFind.BackColor = System.Drawing.Color.Transparent;
            this.btnFind.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnFind.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnFind.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnFind.ButtonPressed = false;
            this.btnFind.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnFind.DownPic = null;
            this.btnFind.ExTag = null;
            this.btnFind.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(1106, 11);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(154, 73);
            this.btnFind.TabIndex = 8;
            this.btnFind.Text = "조회";
            this.btnFind.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnFind.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnFind.UpPic = null;
            this.btnFind.UseFlag = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // Grid1
            // 
            this.Grid1.AutoScroll = true;
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(10, 92);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 693);
            this.Grid1.TabIndex = 64;
            this.Grid1.TabStop = false;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.GridClick += new SmartDas.Components.MESGrid.gridClick(this.Grid1_GridClick);
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // pnlORDER_LOT
            // 
            this.pnlORDER_LOT.Controls.Add(this.txtORDER_NO);
            this.pnlORDER_LOT.Controls.Add(this.lblLOT_NO);
            this.pnlORDER_LOT.Controls.Add(this.txtLOT_NO);
            this.pnlORDER_LOT.Controls.Add(this.lblORDER_NO);
            this.pnlORDER_LOT.Location = new System.Drawing.Point(460, 1);
            this.pnlORDER_LOT.Name = "pnlORDER_LOT";
            this.pnlORDER_LOT.Size = new System.Drawing.Size(288, 88);
            this.pnlORDER_LOT.TabIndex = 237;
            this.pnlORDER_LOT.Visible = false;
            // 
            // txtORDER_NO
            // 
            this.txtORDER_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtORDER_NO.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtORDER_NO.Location = new System.Drawing.Point(120, 8);
            this.txtORDER_NO.MaxLength = 15;
            this.txtORDER_NO.MinimumSize = new System.Drawing.Size(0, 32);
            this.txtORDER_NO.Name = "txtORDER_NO";
            this.txtORDER_NO.Size = new System.Drawing.Size(154, 32);
            this.txtORDER_NO.TabIndex = 2;
            // 
            // lblLOT_NO
            // 
            this.lblLOT_NO.BackColor = System.Drawing.Color.Gray;
            this.lblLOT_NO.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLOT_NO.ForeColor = System.Drawing.Color.White;
            this.lblLOT_NO.Location = new System.Drawing.Point(8, 49);
            this.lblLOT_NO.Name = "lblLOT_NO";
            this.lblLOT_NO.Size = new System.Drawing.Size(106, 32);
            this.lblLOT_NO.TabIndex = 236;
            this.lblLOT_NO.Text = "LOT 번호";
            this.lblLOT_NO.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtLOT_NO
            // 
            this.txtLOT_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtLOT_NO.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtLOT_NO.Location = new System.Drawing.Point(120, 49);
            this.txtLOT_NO.MaxLength = 15;
            this.txtLOT_NO.MinimumSize = new System.Drawing.Size(0, 32);
            this.txtLOT_NO.Name = "txtLOT_NO";
            this.txtLOT_NO.Size = new System.Drawing.Size(154, 32);
            this.txtLOT_NO.TabIndex = 3;
            // 
            // lblORDER_NO
            // 
            this.lblORDER_NO.BackColor = System.Drawing.Color.Gray;
            this.lblORDER_NO.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblORDER_NO.ForeColor = System.Drawing.Color.White;
            this.lblORDER_NO.Location = new System.Drawing.Point(8, 8);
            this.lblORDER_NO.Name = "lblORDER_NO";
            this.lblORDER_NO.Size = new System.Drawing.Size(106, 32);
            this.lblORDER_NO.TabIndex = 234;
            this.lblORDER_NO.Text = "오더 번호";
            this.lblORDER_NO.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // POP_WRK07
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK07";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK07_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.pnlORDER_LOT.ResumeLayout(false);
            this.pnlORDER_LOT.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lblREQ_DATE;
        private System.Windows.Forms.Label lblMATNR;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private System.Windows.Forms.DateTimePicker dtpREQ_STR_DATE;
        private MESLabel lblRemark;
        private System.Windows.Forms.DateTimePicker dtpREQ_END_DATE;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label lblPW;
        private System.Windows.Forms.TextBox txtMATNR;
        private System.Windows.Forms.TextBox txtWEIGHT;
        private System.Windows.Forms.TextBox txtPCODE;
        private System.Windows.Forms.Button btnREQ_END_DATE;
        private System.Windows.Forms.Button btnREQ_STR_DATE;
        private System.Windows.Forms.TextBox txtVLEN;
        private System.Windows.Forms.TextBox txtWLEN;
        private System.Windows.Forms.Label lblWV;
        private System.Windows.Forms.TextBox txtLOT_NO;
        private System.Windows.Forms.TextBox txtORDER_NO;
        private System.Windows.Forms.Label lblORDER_NO;
        private System.Windows.Forms.Label lblLOT_NO;
        private System.Windows.Forms.Panel pnlORDER_LOT;

    }
}
