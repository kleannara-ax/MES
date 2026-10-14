using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK30
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
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            Infragistics.Win.ValueListItem valueListItem14 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem15 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            Infragistics.Win.ValueListItem valueListItem1 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem2 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem3 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem4 = new Infragistics.Win.ValueListItem();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK30));
            this.label2 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.txtPrfmQty = new System.Windows.Forms.TextBox();
            this.lblPrfmQty = new System.Windows.Forms.Label();
            this.txtPltCnt = new System.Windows.Forms.TextBox();
            this.lblPltCnt = new System.Windows.Forms.Label();
            this.txtUSERNM = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtVLEN = new System.Windows.Forms.TextBox();
            this.txtWLEN = new System.Windows.Forms.TextBox();
            this.lblWV = new System.Windows.Forms.Label();
            this.butWorkEndDate = new System.Windows.Forms.Button();
            this.cboWorkEndDate = new System.Windows.Forms.DateTimePicker();
            this.butWorkStartDate = new System.Windows.Forms.Button();
            this.txtBS_WGT = new System.Windows.Forms.TextBox();
            this.txtPCODE = new System.Windows.Forms.TextBox();
            this.txtIND_BCD = new System.Windows.Forms.TextBox();
            this.txtORDER_NO = new System.Windows.Forms.TextBox();
            this.cboWorkStartDate = new System.Windows.Forms.DateTimePicker();
            this.lblLabel4 = new System.Windows.Forms.Label();
            this.lblLabel5 = new System.Windows.Forms.Label();
            this.lblLabel2 = new System.Windows.Forms.Label();
            this.pnlPRINT = new System.Windows.Forms.Panel();
            this.ucPNT_CNT = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.ucLABEL_TYPE = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.lblPNT_CNT = new System.Windows.Forms.Label();
            this.lblLABEL_TYPE = new System.Windows.Forms.Label();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.label4 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.pnlPRINT.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ucPNT_CNT)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ucLABEL_TYPE)).BeginInit();
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
            // lblMessage
            // 
            this.lblMessage.Position = 623;
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(9, 10);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(106, 35);
            this.label2.TabIndex = 49;
            this.label2.Text = "실적일자";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.bBox1.ExTag = "-";
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
            this.splitContainer1.Panel1.Controls.Add(this.txtPrfmQty);
            this.splitContainer1.Panel1.Controls.Add(this.lblPrfmQty);
            this.splitContainer1.Panel1.Controls.Add(this.txtPltCnt);
            this.splitContainer1.Panel1.Controls.Add(this.lblPltCnt);
            this.splitContainer1.Panel1.Controls.Add(this.txtUSERNM);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.txtVLEN);
            this.splitContainer1.Panel1.Controls.Add(this.txtWLEN);
            this.splitContainer1.Panel1.Controls.Add(this.lblWV);
            this.splitContainer1.Panel1.Controls.Add(this.butWorkEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.cboWorkEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butWorkStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.txtBS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.txtPCODE);
            this.splitContainer1.Panel1.Controls.Add(this.txtIND_BCD);
            this.splitContainer1.Panel1.Controls.Add(this.txtORDER_NO);
            this.splitContainer1.Panel1.Controls.Add(this.cboWorkStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel4);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel5);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel2);
            this.splitContainer1.Panel1.Controls.Add(this.pnlPRINT);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // txtPrfmQty
            // 
            this.txtPrfmQty.BackColor = System.Drawing.SystemColors.Window;
            this.txtPrfmQty.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtPrfmQty.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPrfmQty.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtPrfmQty.Location = new System.Drawing.Point(1100, 745);
            this.txtPrfmQty.MaxLength = 10;
            this.txtPrfmQty.Multiline = true;
            this.txtPrfmQty.Name = "txtPrfmQty";
            this.txtPrfmQty.ReadOnly = true;
            this.txtPrfmQty.Size = new System.Drawing.Size(154, 40);
            this.txtPrfmQty.TabIndex = 301;
            this.txtPrfmQty.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // lblPrfmQty
            // 
            this.lblPrfmQty.BackColor = System.Drawing.Color.Black;
            this.lblPrfmQty.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPrfmQty.ForeColor = System.Drawing.Color.White;
            this.lblPrfmQty.Location = new System.Drawing.Point(969, 745);
            this.lblPrfmQty.Name = "lblPrfmQty";
            this.lblPrfmQty.Size = new System.Drawing.Size(125, 40);
            this.lblPrfmQty.TabIndex = 300;
            this.lblPrfmQty.Text = "실적량";
            this.lblPrfmQty.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtPltCnt
            // 
            this.txtPltCnt.BackColor = System.Drawing.SystemColors.Window;
            this.txtPltCnt.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtPltCnt.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPltCnt.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtPltCnt.Location = new System.Drawing.Point(784, 745);
            this.txtPltCnt.MaxLength = 10;
            this.txtPltCnt.Multiline = true;
            this.txtPltCnt.Name = "txtPltCnt";
            this.txtPltCnt.ReadOnly = true;
            this.txtPltCnt.Size = new System.Drawing.Size(154, 40);
            this.txtPltCnt.TabIndex = 299;
            this.txtPltCnt.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // lblPltCnt
            // 
            this.lblPltCnt.BackColor = System.Drawing.Color.Black;
            this.lblPltCnt.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPltCnt.ForeColor = System.Drawing.Color.White;
            this.lblPltCnt.Location = new System.Drawing.Point(653, 745);
            this.lblPltCnt.Name = "lblPltCnt";
            this.lblPltCnt.Size = new System.Drawing.Size(125, 40);
            this.lblPltCnt.TabIndex = 278;
            this.lblPltCnt.Text = "팔렛트수";
            this.lblPltCnt.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtUSERNM
            // 
            this.txtUSERNM.BackColor = System.Drawing.SystemColors.Window;
            this.txtUSERNM.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtUSERNM.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtUSERNM.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtUSERNM.Location = new System.Drawing.Point(124, 54);
            this.txtUSERNM.MaxLength = 10;
            this.txtUSERNM.Name = "txtUSERNM";
            this.txtUSERNM.Size = new System.Drawing.Size(142, 39);
            this.txtUSERNM.TabIndex = 298;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(9, 54);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(106, 32);
            this.label1.TabIndex = 297;
            this.label1.Text = "작업자";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtVLEN
            // 
            this.txtVLEN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtVLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtVLEN.Location = new System.Drawing.Point(989, 52);
            this.txtVLEN.MaxLength = 5;
            this.txtVLEN.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtVLEN.Name = "txtVLEN";
            this.txtVLEN.Size = new System.Drawing.Size(100, 39);
            this.txtVLEN.TabIndex = 295;
            this.txtVLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtVLEN.Visible = false;
            this.txtVLEN.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_KeyPress);
            // 
            // txtWLEN
            // 
            this.txtWLEN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtWLEN.Location = new System.Drawing.Point(883, 52);
            this.txtWLEN.MaxLength = 6;
            this.txtWLEN.MinimumSize = new System.Drawing.Size(100, 32);
            this.txtWLEN.Name = "txtWLEN";
            this.txtWLEN.Size = new System.Drawing.Size(100, 39);
            this.txtWLEN.TabIndex = 294;
            this.txtWLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtWLEN.Visible = false;
            this.txtWLEN.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_KeyPress);
            // 
            // lblWV
            // 
            this.lblWV.BackColor = System.Drawing.Color.Gray;
            this.lblWV.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWV.ForeColor = System.Drawing.Color.White;
            this.lblWV.Location = new System.Drawing.Point(771, 52);
            this.lblWV.Name = "lblWV";
            this.lblWV.Size = new System.Drawing.Size(106, 32);
            this.lblWV.TabIndex = 296;
            this.lblWV.Text = "가로/세로";
            this.lblWV.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblWV.Visible = false;
            // 
            // butWorkEndDate
            // 
            this.butWorkEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butWorkEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butWorkEndDate.CausesValidation = false;
            this.butWorkEndDate.FlatAppearance.BorderSize = 0;
            this.butWorkEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butWorkEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butWorkEndDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butWorkEndDate.Location = new System.Drawing.Point(416, 12);
            this.butWorkEndDate.Name = "butWorkEndDate";
            this.butWorkEndDate.Size = new System.Drawing.Size(26, 32);
            this.butWorkEndDate.TabIndex = 292;
            this.butWorkEndDate.UseVisualStyleBackColor = false;
            this.butWorkEndDate.Click += new System.EventHandler(this.butWorkEndDate_Click);
            // 
            // cboWorkEndDate
            // 
            this.cboWorkEndDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cboWorkEndDate.CustomFormat = "yyyy-MM-dd";
            this.cboWorkEndDate.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cboWorkEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.cboWorkEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.cboWorkEndDate.Location = new System.Drawing.Point(302, 11);
            this.cboWorkEndDate.MinimumSize = new System.Drawing.Size(0, 35);
            this.cboWorkEndDate.Name = "cboWorkEndDate";
            this.cboWorkEndDate.ShowUpDown = true;
            this.cboWorkEndDate.Size = new System.Drawing.Size(142, 35);
            this.cboWorkEndDate.TabIndex = 291;
            // 
            // butWorkStartDate
            // 
            this.butWorkStartDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butWorkStartDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butWorkStartDate.CausesValidation = false;
            this.butWorkStartDate.FlatAppearance.BorderSize = 0;
            this.butWorkStartDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butWorkStartDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butWorkStartDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butWorkStartDate.Location = new System.Drawing.Point(238, 11);
            this.butWorkStartDate.Name = "butWorkStartDate";
            this.butWorkStartDate.Size = new System.Drawing.Size(26, 32);
            this.butWorkStartDate.TabIndex = 130;
            this.butWorkStartDate.UseVisualStyleBackColor = false;
            this.butWorkStartDate.Click += new System.EventHandler(this.butWorkStartDate_Click);
            // 
            // txtBS_WGT
            // 
            this.txtBS_WGT.BackColor = System.Drawing.SystemColors.Window;
            this.txtBS_WGT.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtBS_WGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtBS_WGT.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtBS_WGT.Location = new System.Drawing.Point(988, 10);
            this.txtBS_WGT.MaxLength = 10;
            this.txtBS_WGT.Name = "txtBS_WGT";
            this.txtBS_WGT.Size = new System.Drawing.Size(99, 39);
            this.txtBS_WGT.TabIndex = 290;
            this.txtBS_WGT.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_KeyPress);
            // 
            // txtPCODE
            // 
            this.txtPCODE.BackColor = System.Drawing.SystemColors.Window;
            this.txtPCODE.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtPCODE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPCODE.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtPCODE.Location = new System.Drawing.Point(883, 10);
            this.txtPCODE.MaxLength = 10;
            this.txtPCODE.Name = "txtPCODE";
            this.txtPCODE.Size = new System.Drawing.Size(100, 39);
            this.txtPCODE.TabIndex = 289;
            this.txtPCODE.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // txtIND_BCD
            // 
            this.txtIND_BCD.BackColor = System.Drawing.SystemColors.Window;
            this.txtIND_BCD.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtIND_BCD.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtIND_BCD.Location = new System.Drawing.Point(602, 51);
            this.txtIND_BCD.MaxLength = 10;
            this.txtIND_BCD.Name = "txtIND_BCD";
            this.txtIND_BCD.Size = new System.Drawing.Size(154, 39);
            this.txtIND_BCD.TabIndex = 288;
            // 
            // txtORDER_NO
            // 
            this.txtORDER_NO.BackColor = System.Drawing.SystemColors.Window;
            this.txtORDER_NO.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtORDER_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtORDER_NO.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtORDER_NO.Location = new System.Drawing.Point(602, 9);
            this.txtORDER_NO.MaxLength = 10;
            this.txtORDER_NO.Name = "txtORDER_NO";
            this.txtORDER_NO.Size = new System.Drawing.Size(154, 39);
            this.txtORDER_NO.TabIndex = 287;
            // 
            // cboWorkStartDate
            // 
            this.cboWorkStartDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cboWorkStartDate.CustomFormat = "yyyy-MM-dd";
            this.cboWorkStartDate.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cboWorkStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.cboWorkStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.cboWorkStartDate.Location = new System.Drawing.Point(124, 10);
            this.cboWorkStartDate.MinimumSize = new System.Drawing.Size(0, 35);
            this.cboWorkStartDate.Name = "cboWorkStartDate";
            this.cboWorkStartDate.ShowUpDown = true;
            this.cboWorkStartDate.Size = new System.Drawing.Size(142, 35);
            this.cboWorkStartDate.TabIndex = 124;
            // 
            // lblLabel4
            // 
            this.lblLabel4.BackColor = System.Drawing.Color.Gray;
            this.lblLabel4.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel4.ForeColor = System.Drawing.Color.White;
            this.lblLabel4.Location = new System.Drawing.Point(490, 10);
            this.lblLabel4.Name = "lblLabel4";
            this.lblLabel4.Size = new System.Drawing.Size(106, 32);
            this.lblLabel4.TabIndex = 283;
            this.lblLabel4.Text = "오더번호";
            this.lblLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel5
            // 
            this.lblLabel5.BackColor = System.Drawing.Color.Gray;
            this.lblLabel5.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel5.ForeColor = System.Drawing.Color.White;
            this.lblLabel5.Location = new System.Drawing.Point(490, 51);
            this.lblLabel5.Name = "lblLabel5";
            this.lblLabel5.Size = new System.Drawing.Size(106, 32);
            this.lblLabel5.TabIndex = 285;
            this.lblLabel5.Text = "바코드";
            this.lblLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel2
            // 
            this.lblLabel2.BackColor = System.Drawing.Color.Gray;
            this.lblLabel2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel2.ForeColor = System.Drawing.Color.White;
            this.lblLabel2.Location = new System.Drawing.Point(771, 11);
            this.lblLabel2.Name = "lblLabel2";
            this.lblLabel2.Size = new System.Drawing.Size(106, 32);
            this.lblLabel2.TabIndex = 279;
            this.lblLabel2.Text = "지종/평량";
            this.lblLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // pnlPRINT
            // 
            this.pnlPRINT.Controls.Add(this.ucPNT_CNT);
            this.pnlPRINT.Controls.Add(this.ucLABEL_TYPE);
            this.pnlPRINT.Controls.Add(this.lblPNT_CNT);
            this.pnlPRINT.Controls.Add(this.lblLABEL_TYPE);
            this.pnlPRINT.Location = new System.Drawing.Point(9, 742);
            this.pnlPRINT.Name = "pnlPRINT";
            this.pnlPRINT.Size = new System.Drawing.Size(620, 45);
            this.pnlPRINT.TabIndex = 278;
            this.pnlPRINT.Visible = false;
            // 
            // ucPNT_CNT
            // 
            appearance1.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPNT_CNT.Appearance = appearance1;
            this.ucPNT_CNT.AutoSize = false;
            this.ucPNT_CNT.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPNT_CNT.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucPNT_CNT.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.ucPNT_CNT.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            valueListItem14.DataValue = "ValueListItem1";
            valueListItem14.DisplayText = "1 매";
            valueListItem15.DataValue = "ValueListItem2";
            valueListItem15.DisplayText = "2 매";
            this.ucPNT_CNT.Items.AddRange(new Infragistics.Win.ValueListItem[] {
            valueListItem14,
            valueListItem15});
            this.ucPNT_CNT.Location = new System.Drawing.Point(444, 3);
            this.ucPNT_CNT.Name = "ucPNT_CNT";
            this.ucPNT_CNT.Size = new System.Drawing.Size(166, 40);
            this.ucPNT_CNT.TabIndex = 277;
            this.ucPNT_CNT.Visible = false;
            // 
            // ucLABEL_TYPE
            // 
            appearance2.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucLABEL_TYPE.Appearance = appearance2;
            this.ucLABEL_TYPE.AutoSize = false;
            this.ucLABEL_TYPE.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucLABEL_TYPE.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucLABEL_TYPE.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.ucLABEL_TYPE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            valueListItem1.DataValue = "01";
            valueListItem1.DisplayText = "내수 - 페이퍼";
            valueListItem2.DataValue = "02";
            valueListItem2.DisplayText = "내수 - 스티커";
            valueListItem3.DataValue = "03";
            valueListItem3.DisplayText = "수출 - 페이퍼";
            valueListItem4.DataValue = "04";
            valueListItem4.DisplayText = "수출 - 스티커";
            this.ucLABEL_TYPE.Items.AddRange(new Infragistics.Win.ValueListItem[] {
            valueListItem1,
            valueListItem2,
            valueListItem3,
            valueListItem4});
            this.ucLABEL_TYPE.Location = new System.Drawing.Point(134, 3);
            this.ucLABEL_TYPE.MinimumSize = new System.Drawing.Size(0, 40);
            this.ucLABEL_TYPE.Name = "ucLABEL_TYPE";
            this.ucLABEL_TYPE.Size = new System.Drawing.Size(166, 40);
            this.ucLABEL_TYPE.TabIndex = 276;
            this.ucLABEL_TYPE.Visible = false;
            // 
            // lblPNT_CNT
            // 
            this.lblPNT_CNT.BackColor = System.Drawing.Color.Black;
            this.lblPNT_CNT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPNT_CNT.ForeColor = System.Drawing.Color.White;
            this.lblPNT_CNT.Location = new System.Drawing.Point(313, 3);
            this.lblPNT_CNT.Name = "lblPNT_CNT";
            this.lblPNT_CNT.Size = new System.Drawing.Size(125, 40);
            this.lblPNT_CNT.TabIndex = 274;
            this.lblPNT_CNT.Text = "인쇄매수";
            this.lblPNT_CNT.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblPNT_CNT.Visible = false;
            // 
            // lblLABEL_TYPE
            // 
            this.lblLABEL_TYPE.BackColor = System.Drawing.Color.Black;
            this.lblLABEL_TYPE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLABEL_TYPE.ForeColor = System.Drawing.Color.White;
            this.lblLABEL_TYPE.Location = new System.Drawing.Point(3, 3);
            this.lblLABEL_TYPE.Name = "lblLABEL_TYPE";
            this.lblLABEL_TYPE.Size = new System.Drawing.Size(125, 40);
            this.lblLABEL_TYPE.TabIndex = 275;
            this.lblLABEL_TYPE.Text = "라벨양식";
            this.lblLABEL_TYPE.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblLABEL_TYPE.Visible = false;
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
            this.btnFind.Location = new System.Drawing.Point(1107, 11);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(152, 72);
            this.btnFind.TabIndex = 125;
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
            this.Grid1.Location = new System.Drawing.Point(9, 92);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 641);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.Location = new System.Drawing.Point(268, 12);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(39, 41);
            this.label4.TabIndex = 293;
            this.label4.Text = "~";
            // 
            // POP_WRK30
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK30";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK30_Load);
            this.Shown += new System.EventHandler(this.POP_WRK30_Shown);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.pnlPRINT.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.ucPNT_CNT)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ucLABEL_TYPE)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private System.Windows.Forms.DateTimePicker cboWorkStartDate;
        private MESButton btnFind;
        private System.Windows.Forms.Button butWorkStartDate;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucLABEL_TYPE;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucPNT_CNT;
        private System.Windows.Forms.Label lblLABEL_TYPE;
        private System.Windows.Forms.Label lblPNT_CNT;
        private System.Windows.Forms.Panel pnlPRINT;
        private System.Windows.Forms.Label lblLabel4;
        private System.Windows.Forms.Label lblLabel5;
        private System.Windows.Forms.Label lblLabel2;
        private System.Windows.Forms.TextBox txtBS_WGT;
        private System.Windows.Forms.TextBox txtPCODE;
        private System.Windows.Forms.TextBox txtIND_BCD;
        private System.Windows.Forms.TextBox txtORDER_NO;
        private System.Windows.Forms.Button butWorkEndDate;
        private System.Windows.Forms.DateTimePicker cboWorkEndDate;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox txtUSERNM;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtVLEN;
        private System.Windows.Forms.TextBox txtWLEN;
        private System.Windows.Forms.Label lblWV;
        private System.Windows.Forms.TextBox txtPrfmQty;
        private System.Windows.Forms.Label lblPrfmQty;
        private System.Windows.Forms.TextBox txtPltCnt;
        private System.Windows.Forms.Label lblPltCnt;
    }
}
