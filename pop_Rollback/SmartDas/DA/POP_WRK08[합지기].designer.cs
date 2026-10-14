using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK08
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK08));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblUNIT2 = new SmartDas.Components.MESLabel();
            this.lblUNIT1 = new SmartDas.Components.MESLabel();
            this.btnPRD_END_DATE = new System.Windows.Forms.Button();
            this.btnPRD_STR_DATE = new System.Windows.Forms.Button();
            this.lblMACH_STA = new System.Windows.Forms.Label();
            this.lblPRD_END_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.label11 = new System.Windows.Forms.Label();
            this.lblPRD_STR_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.label9 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.lblPRFM_QTY = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_RMK = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblORDER_QTY = new SmartDas.Components.MESLabel();
            this.lblPRD_REQ_DATE = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.lblMATNR_SPEC = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblSPEC = new SmartDas.Components.MESLabel();
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
            this.splitContainer1.Panel1.Controls.Add(this.lblUNIT2);
            this.splitContainer1.Panel1.Controls.Add(this.lblUNIT1);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.lblMACH_STA);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_END_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_STR_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblORDER_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR_SPEC);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblSPEC);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblUNIT2
            // 
            this.lblUNIT2.BackColor = System.Drawing.Color.LightGray;
            this.lblUNIT2.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblUNIT2.ColorContent = System.Drawing.Color.Transparent;
            this.lblUNIT2.ColorLabel = System.Drawing.Color.LightGray;
            this.lblUNIT2.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblUNIT2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblUNIT2.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblUNIT2.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblUNIT2.Location = new System.Drawing.Point(1163, 66);
            this.lblUNIT2.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblUNIT2.MoveControl = null;
            this.lblUNIT2.Name = "lblUNIT2";
            this.lblUNIT2.Size = new System.Drawing.Size(90, 50);
            this.lblUNIT2.TabIndex = 223;
            this.lblUNIT2.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblUNIT2.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblUNIT1
            // 
            this.lblUNIT1.BackColor = System.Drawing.Color.LightGray;
            this.lblUNIT1.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblUNIT1.ColorContent = System.Drawing.Color.Transparent;
            this.lblUNIT1.ColorLabel = System.Drawing.Color.LightGray;
            this.lblUNIT1.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblUNIT1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblUNIT1.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblUNIT1.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblUNIT1.Location = new System.Drawing.Point(1163, 10);
            this.lblUNIT1.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblUNIT1.MoveControl = null;
            this.lblUNIT1.Name = "lblUNIT1";
            this.lblUNIT1.Size = new System.Drawing.Size(90, 50);
            this.lblUNIT1.TabIndex = 222;
            this.lblUNIT1.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblUNIT1.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnPRD_END_DATE.Location = new System.Drawing.Point(440, 349);
            this.btnPRD_END_DATE.Name = "btnPRD_END_DATE";
            this.btnPRD_END_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_END_DATE.TabIndex = 221;
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
            this.btnPRD_STR_DATE.Location = new System.Drawing.Point(440, 293);
            this.btnPRD_STR_DATE.Name = "btnPRD_STR_DATE";
            this.btnPRD_STR_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_STR_DATE.TabIndex = 220;
            this.btnPRD_STR_DATE.Tag = "startDate";
            this.btnPRD_STR_DATE.UseVisualStyleBackColor = false;
            this.btnPRD_STR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // lblMACH_STA
            // 
            this.lblMACH_STA.BackColor = System.Drawing.Color.Black;
            this.lblMACH_STA.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMACH_STA.ForeColor = System.Drawing.Color.Lime;
            this.lblMACH_STA.Location = new System.Drawing.Point(693, 290);
            this.lblMACH_STA.Name = "lblMACH_STA";
            this.lblMACH_STA.Size = new System.Drawing.Size(560, 105);
            this.lblMACH_STA.TabIndex = 217;
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
            this.lblPRD_END_TIME.Location = new System.Drawing.Point(505, 346);
            this.lblPRD_END_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_END_TIME.MoveControl = null;
            this.lblPRD_END_TIME.Name = "lblPRD_END_TIME";
            this.lblPRD_END_TIME.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_END_TIME.TabIndex = 216;
            this.lblPRD_END_TIME.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_END_TIME.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_END_TIME.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_END_DATE
            // 
            this.dtpPRD_END_DATE.CalendarFont = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_END_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_END_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_END_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_END_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_END_DATE.Location = new System.Drawing.Point(168, 346);
            this.dtpPRD_END_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_END_DATE.Name = "dtpPRD_END_DATE";
            this.dtpPRD_END_DATE.ShowUpDown = true;
            this.dtpPRD_END_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_END_DATE.TabIndex = 215;
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
            this.label11.TabIndex = 214;
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
            this.lblPRD_STR_TIME.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_STR_TIME.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_STR_TIME.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_STR_TIME.Location = new System.Drawing.Point(505, 290);
            this.lblPRD_STR_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_STR_TIME.MoveControl = null;
            this.lblPRD_STR_TIME.Name = "lblPRD_STR_TIME";
            this.lblPRD_STR_TIME.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_STR_TIME.TabIndex = 213;
            this.lblPRD_STR_TIME.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_STR_TIME.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_STR_TIME.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_STR_DATE
            // 
            this.dtpPRD_STR_DATE.CalendarFont = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_STR_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(168, 290);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_STR_DATE.TabIndex = 212;
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Black;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(13, 290);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(150, 50);
            this.label9.TabIndex = 211;
            this.label9.Text = "시작일시";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(843, 66);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(150, 50);
            this.label7.TabIndex = 156;
            this.label7.Text = "실적량";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_QTY
            // 
            this.lblPRFM_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFM_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFM_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_QTY.Location = new System.Drawing.Point(1001, 66);
            this.lblPRFM_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_QTY.MoveControl = null;
            this.lblPRFM_QTY.Name = "lblPRFM_QTY";
            this.lblPRFM_QTY.Size = new System.Drawing.Size(160, 50);
            this.lblPRFM_QTY.TabIndex = 157;
            this.lblPRFM_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.lblWRK_ORDR_RMK.Location = new System.Drawing.Point(168, 234);
            this.lblWRK_ORDR_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_RMK.MoveControl = null;
            this.lblWRK_ORDR_RMK.Name = "lblWRK_ORDR_RMK";
            this.lblWRK_ORDR_RMK.Size = new System.Drawing.Size(1085, 50);
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
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(168, 66);
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
            this.label4.Location = new System.Drawing.Point(843, 10);
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
            this.lblORDER_QTY.Location = new System.Drawing.Point(1001, 10);
            this.lblORDER_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblORDER_QTY.MoveControl = null;
            this.lblORDER_QTY.Name = "lblORDER_QTY";
            this.lblORDER_QTY.Size = new System.Drawing.Size(160, 50);
            this.lblORDER_QTY.TabIndex = 151;
            this.lblORDER_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblORDER_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPRD_REQ_DATE
            // 
            this.lblPRD_REQ_DATE.BackColor = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DATE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_REQ_DATE.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DATE.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DATE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DATE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DATE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DATE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DATE.Location = new System.Drawing.Point(168, 10);
            this.lblPRD_REQ_DATE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DATE.MoveControl = null;
            this.lblPRD_REQ_DATE.Name = "lblPRD_REQ_DATE";
            this.lblPRD_REQ_DATE.Size = new System.Drawing.Size(670, 50);
            this.lblPRD_REQ_DATE.TabIndex = 149;
            this.lblPRD_REQ_DATE.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRD_REQ_DATE.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(658, 66);
            this.lblWRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO.MoveControl = null;
            this.lblWRK_ORDR_SEQNO.Name = "lblWRK_ORDR_SEQNO";
            this.lblWRK_ORDR_SEQNO.Size = new System.Drawing.Size(180, 50);
            this.lblWRK_ORDR_SEQNO.TabIndex = 148;
            this.lblWRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.lblMATNR_SPEC.Location = new System.Drawing.Point(843, 122);
            this.lblMATNR_SPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR_SPEC.MoveControl = null;
            this.lblMATNR_SPEC.Name = "lblMATNR_SPEC";
            this.lblMATNR_SPEC.Size = new System.Drawing.Size(410, 50);
            this.lblMATNR_SPEC.TabIndex = 147;
            this.lblMATNR_SPEC.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR_SPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.label1.Text = "품목/규격";
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
            this.lblMATNR.Location = new System.Drawing.Point(168, 122);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(670, 50);
            this.lblMATNR.TabIndex = 144;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(13, 178);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 145;
            this.label3.Text = "지폭";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSPEC
            // 
            this.lblSPEC.BackColor = System.Drawing.Color.LightGray;
            this.lblSPEC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblSPEC.ColorContent = System.Drawing.Color.Transparent;
            this.lblSPEC.ColorLabel = System.Drawing.Color.LightGray;
            this.lblSPEC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblSPEC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblSPEC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblSPEC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblSPEC.Location = new System.Drawing.Point(168, 178);
            this.lblSPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblSPEC.MoveControl = null;
            this.lblSPEC.Name = "lblSPEC";
            this.lblSPEC.Size = new System.Drawing.Size(1085, 50);
            this.lblSPEC.TabIndex = 146;
            this.lblSPEC.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblSPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.Automatic;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 380);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.GridClick += new SmartDas.Components.MESGrid.gridClick(this.Grid1_GridClick);
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // timer1
            // 
            this.timer1.Interval = 1000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // POP_WRK08
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK08";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK08_Load);
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
        private MESLabel lblPRD_REQ_DATE;
        private MESLabel lblWRK_ORDR_SEQNO;
        private MESLabel lblMATNR_SPEC;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private MESLabel lblMATNR;
        private System.Windows.Forms.Label label3;
        private MESLabel lblSPEC;
        private System.Windows.Forms.Label label7;
        private MESLabel lblPRFM_QTY;
        private System.Windows.Forms.Label lblMACH_STA;
        private MESLabel lblPRD_END_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_END_DATE;
        private System.Windows.Forms.Label label11;
        private MESLabel lblPRD_STR_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Button btnPRD_END_DATE;
        private System.Windows.Forms.Button btnPRD_STR_DATE;
        private MESLabel lblUNIT2;
        private MESLabel lblUNIT1;
        private System.Windows.Forms.Timer timer1;

    }
}
