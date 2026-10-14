using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK44
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK44));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblUNIT = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblPCODE = new SmartDas.Components.MESLabel();
            this.lblMATNR_SPEC = new SmartDas.Components.MESLabel();
            this.btnPRD_END_DATE = new System.Windows.Forms.Button();
            this.btnPRD_STR_DATE = new System.Windows.Forms.Button();
            this.lblMACH_STA = new System.Windows.Forms.Label();
            this.lblPRD_END_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.label11 = new System.Windows.Forms.Label();
            this.lblPRD_STR_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.label12 = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.lblEA_QTY = new SmartDas.Components.MESLabel();
            this.lblBAG_QTY = new SmartDas.Components.MESLabel();
            this.lblBOX_QTY = new SmartDas.Components.MESLabel();
            this.lblPLT_QTY = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_RMK = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblORDER_QTY = new SmartDas.Components.MESLabel();
            this.lblPRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
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
            this.splitContainer1.Panel1.Controls.Add(this.lblUNIT);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblPCODE);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR_SPEC);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.lblMACH_STA);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_END_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_STR_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.lblEA_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblBAG_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblBOX_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPLT_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblORDER_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblUNIT
            // 
            this.lblUNIT.BackColor = System.Drawing.Color.LightGray;
            this.lblUNIT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblUNIT.ColorContent = System.Drawing.Color.Transparent;
            this.lblUNIT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblUNIT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblUNIT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblUNIT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblUNIT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblUNIT.Location = new System.Drawing.Point(1163, 10);
            this.lblUNIT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblUNIT.MoveControl = null;
            this.lblUNIT.Name = "lblUNIT";
            this.lblUNIT.Size = new System.Drawing.Size(90, 50);
            this.lblUNIT.TabIndex = 246;
            this.lblUNIT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblUNIT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(13, 178);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 244;
            this.label3.Text = "SIZE/규격";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPCODE
            // 
            this.lblPCODE.BackColor = System.Drawing.Color.LightGray;
            this.lblPCODE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPCODE.ColorContent = System.Drawing.Color.Transparent;
            this.lblPCODE.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPCODE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPCODE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPCODE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPCODE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPCODE.Location = new System.Drawing.Point(169, 178);
            this.lblPCODE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPCODE.MoveControl = null;
            this.lblPCODE.Name = "lblPCODE";
            this.lblPCODE.Size = new System.Drawing.Size(330, 50);
            this.lblPCODE.TabIndex = 245;
            this.lblPCODE.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPCODE.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblMATNR_SPEC
            // 
            this.lblMATNR_SPEC.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR_SPEC.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR_SPEC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR_SPEC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR_SPEC.Location = new System.Drawing.Point(509, 178);
            this.lblMATNR_SPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR_SPEC.MoveControl = null;
            this.lblMATNR_SPEC.Name = "lblMATNR_SPEC";
            this.lblMATNR_SPEC.Size = new System.Drawing.Size(330, 50);
            this.lblMATNR_SPEC.TabIndex = 243;
            this.lblMATNR_SPEC.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR_SPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // btnPRD_END_DATE
            // 
            this.btnPRD_END_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnPRD_END_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnPRD_END_DATE.CausesValidation = false;
            this.btnPRD_END_DATE.FlatAppearance.BorderSize = 0;
            this.btnPRD_END_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnPRD_END_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPRD_END_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnPRD_END_DATE.Location = new System.Drawing.Point(441, 349);
            this.btnPRD_END_DATE.Name = "btnPRD_END_DATE";
            this.btnPRD_END_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_END_DATE.TabIndex = 239;
            this.btnPRD_END_DATE.Tag = "endDate";
            this.btnPRD_END_DATE.UseVisualStyleBackColor = false;
            this.btnPRD_END_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // btnPRD_STR_DATE
            // 
            this.btnPRD_STR_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnPRD_STR_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnPRD_STR_DATE.CausesValidation = false;
            this.btnPRD_STR_DATE.FlatAppearance.BorderSize = 0;
            this.btnPRD_STR_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnPRD_STR_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPRD_STR_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnPRD_STR_DATE.Location = new System.Drawing.Point(441, 293);
            this.btnPRD_STR_DATE.Name = "btnPRD_STR_DATE";
            this.btnPRD_STR_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_STR_DATE.TabIndex = 238;
            this.btnPRD_STR_DATE.Tag = "startDate";
            this.btnPRD_STR_DATE.UseVisualStyleBackColor = false;
            this.btnPRD_STR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // lblMACH_STA
            // 
            this.lblMACH_STA.BackColor = System.Drawing.Color.Black;
            this.lblMACH_STA.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMACH_STA.ForeColor = System.Drawing.Color.Lime;
            this.lblMACH_STA.Location = new System.Drawing.Point(694, 290);
            this.lblMACH_STA.Name = "lblMACH_STA";
            this.lblMACH_STA.Size = new System.Drawing.Size(560, 105);
            this.lblMACH_STA.TabIndex = 237;
            this.lblMACH_STA.Text = "진행중";
            this.lblMACH_STA.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblMACH_STA.Click += new System.EventHandler(this.lblStatus_Click);
            // 
            // lblPRD_END_TIME
            // 
            this.lblPRD_END_TIME.BackColor = System.Drawing.Color.White;
            this.lblPRD_END_TIME.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_END_TIME.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_END_TIME.ColorLabel = System.Drawing.Color.White;
            this.lblPRD_END_TIME.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_END_TIME.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_END_TIME.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_END_TIME.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_END_TIME.Location = new System.Drawing.Point(502, 346);
            this.lblPRD_END_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_END_TIME.MoveControl = null;
            this.lblPRD_END_TIME.Name = "lblPRD_END_TIME";
            this.lblPRD_END_TIME.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_END_TIME.TabIndex = 236;
            this.lblPRD_END_TIME.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_END_TIME.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_END_TIME.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_END_DATE
            // 
            this.dtpPRD_END_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_END_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_END_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_END_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_END_DATE.Location = new System.Drawing.Point(169, 346);
            this.dtpPRD_END_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_END_DATE.Name = "dtpPRD_END_DATE";
            this.dtpPRD_END_DATE.ShowUpDown = true;
            this.dtpPRD_END_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_END_DATE.TabIndex = 235;
            this.dtpPRD_END_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Black;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(13, 346);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(150, 50);
            this.label11.TabIndex = 234;
            this.label11.Text = "종료일시";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRD_STR_TIME
            // 
            this.lblPRD_STR_TIME.BackColor = System.Drawing.Color.White;
            this.lblPRD_STR_TIME.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_STR_TIME.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_STR_TIME.ColorLabel = System.Drawing.Color.White;
            this.lblPRD_STR_TIME.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_STR_TIME.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_STR_TIME.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_STR_TIME.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_STR_TIME.Location = new System.Drawing.Point(502, 290);
            this.lblPRD_STR_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_STR_TIME.MoveControl = null;
            this.lblPRD_STR_TIME.Name = "lblPRD_STR_TIME";
            this.lblPRD_STR_TIME.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_STR_TIME.TabIndex = 233;
            this.lblPRD_STR_TIME.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_STR_TIME.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_STR_TIME.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_STR_DATE
            // 
            this.dtpPRD_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_STR_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(169, 290);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_STR_DATE.TabIndex = 232;
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Black;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(13, 290);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(150, 50);
            this.label12.TabIndex = 231;
            this.label12.Text = "시작일시";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(845, 66);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(55, 217);
            this.label13.TabIndex = 230;
            this.label13.Text = "실 적 량";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(905, 234);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(90, 50);
            this.label10.TabIndex = 229;
            this.label10.Text = "EA";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(905, 178);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(90, 50);
            this.label9.TabIndex = 228;
            this.label9.Text = "BAG";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Gray;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(905, 122);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(90, 50);
            this.label8.TabIndex = 227;
            this.label8.Text = "BOX";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(905, 66);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(90, 50);
            this.label7.TabIndex = 226;
            this.label7.Text = "PLT";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblEA_QTY
            // 
            this.lblEA_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblEA_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEA_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblEA_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblEA_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEA_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEA_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEA_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEA_QTY.Location = new System.Drawing.Point(1003, 234);
            this.lblEA_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEA_QTY.MoveControl = null;
            this.lblEA_QTY.Name = "lblEA_QTY";
            this.lblEA_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblEA_QTY.TabIndex = 163;
            this.lblEA_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblEA_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblBAG_QTY
            // 
            this.lblBAG_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblBAG_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBAG_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblBAG_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBAG_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBAG_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBAG_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBAG_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBAG_QTY.Location = new System.Drawing.Point(1003, 178);
            this.lblBAG_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBAG_QTY.MoveControl = null;
            this.lblBAG_QTY.Name = "lblBAG_QTY";
            this.lblBAG_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBAG_QTY.TabIndex = 161;
            this.lblBAG_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBAG_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblBOX_QTY
            // 
            this.lblBOX_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblBOX_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBOX_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblBOX_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBOX_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBOX_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBOX_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBOX_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBOX_QTY.Location = new System.Drawing.Point(1003, 122);
            this.lblBOX_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBOX_QTY.MoveControl = null;
            this.lblBOX_QTY.Name = "lblBOX_QTY";
            this.lblBOX_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBOX_QTY.TabIndex = 159;
            this.lblBOX_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBOX_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPLT_QTY
            // 
            this.lblPLT_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblPLT_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPLT_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblPLT_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPLT_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPLT_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPLT_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPLT_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPLT_QTY.Location = new System.Drawing.Point(1003, 66);
            this.lblPLT_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPLT_QTY.MoveControl = null;
            this.lblPLT_QTY.Name = "lblPLT_QTY";
            this.lblPLT_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblPLT_QTY.TabIndex = 157;
            this.lblPLT_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPLT_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(13, 234);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(150, 50);
            this.label6.TabIndex = 154;
            this.label6.Text = "비고";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_RMK
            // 
            this.lblWRK_ORDR_RMK.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_RMK.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_RMK.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_RMK.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_RMK.Location = new System.Drawing.Point(169, 234);
            this.lblWRK_ORDR_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_RMK.MoveControl = null;
            this.lblWRK_ORDR_RMK.Name = "lblWRK_ORDR_RMK";
            this.lblWRK_ORDR_RMK.Size = new System.Drawing.Size(670, 50);
            this.lblWRK_ORDR_RMK.TabIndex = 155;
            this.lblWRK_ORDR_RMK.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_RMK.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(13, 66);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(150, 50);
            this.label5.TabIndex = 152;
            this.label5.Text = "작업지시번호";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_NO
            // 
            this.lblWRK_ORDR_NO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(169, 66);
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
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(845, 10);
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
            this.lblORDER_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblORDER_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblORDER_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblORDER_QTY.Location = new System.Drawing.Point(1003, 10);
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
            this.lblPRD_REQ_DT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DT.Location = new System.Drawing.Point(169, 10);
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
            this.lblWRK_ORDR_SEQNO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_SEQNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_SEQNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(659, 66);
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
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(13, 10);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 142;
            this.label2.Text = "생산요청일";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(13, 122);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 143;
            this.label1.Text = "품목";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(169, 122);
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
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(10, 400);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 380);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // timer1
            // 
            this.timer1.Interval = 1000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // POP_WRK44
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK44";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK44_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private System.Windows.Forms.Label label6;
        private MESLabel lblWRK_ORDR_RMK;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWRK_ORDR_NO;
        private System.Windows.Forms.Label label4;
        private MESLabel lblORDER_QTY;
        private MESLabel lblPRD_REQ_DT;
        private MESLabel lblWRK_ORDR_SEQNO;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private MESLabel lblMATNR;
        private MESLabel lblEA_QTY;
        private MESLabel lblBAG_QTY;
        private MESLabel lblBOX_QTY;
        private MESLabel lblPLT_QTY;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label lblMACH_STA;
        private MESLabel lblPRD_END_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_END_DATE;
        private System.Windows.Forms.Label label11;
        private MESLabel lblPRD_STR_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.Button btnPRD_END_DATE;
        private System.Windows.Forms.Button btnPRD_STR_DATE;
        private System.Windows.Forms.Label label3;
        private MESLabel lblPCODE;
        private MESLabel lblMATNR_SPEC;
        private MESLabel lblUNIT;
        private System.Windows.Forms.Timer timer1;

    }
}
