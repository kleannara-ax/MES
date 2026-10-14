using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK40
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
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblWRK_ORDR_SEQNO_N = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.txtWRK_ORDR_RMK_N = new System.Windows.Forms.TextBox();
            this.txtWRK_ORDR_RMK = new System.Windows.Forms.TextBox();
            this.butStartDateN = new System.Windows.Forms.Button();
            this.butEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.dtpStartDateN = new System.Windows.Forms.DateTimePicker();
            this.lblStartTimeN = new SmartDas.Components.MESLabel();
            this.label25 = new System.Windows.Forms.Label();
            this.dtpEndDate = new System.Windows.Forms.DateTimePicker();
            this.dtpStartDate = new System.Windows.Forms.DateTimePicker();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.label24 = new System.Windows.Forms.Label();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.label23 = new System.Windows.Forms.Label();
            this.lblWIDTH_N = new SmartDas.Components.MESLabel();
            this.label10 = new System.Windows.Forms.Label();
            this.lblDISPO_QTY_N = new SmartDas.Components.MESLabel();
            this.label11 = new System.Windows.Forms.Label();
            this.lblTOT_WGT_N = new SmartDas.Components.MESLabel();
            this.label12 = new System.Windows.Forms.Label();
            this.lblPRFM_WGT_N = new SmartDas.Components.MESLabel();
            this.label13 = new System.Windows.Forms.Label();
            this.lblJROLLCNT_N = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.lblPRFM_ROLLCNT_N = new SmartDas.Components.MESLabel();
            this.label19 = new System.Windows.Forms.Label();
            this.lblMATNR_N = new SmartDas.Components.MESLabel();
            this.label20 = new System.Windows.Forms.Label();
            this.lblBS_WGT_N = new SmartDas.Components.MESLabel();
            this.label21 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO_N = new SmartDas.Components.MESLabel();
            this.label22 = new System.Windows.Forms.Label();
            this.lblPRD_REQ_DT_N = new SmartDas.Components.MESLabel();
            this.lblWIDTH = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.lblDISPO_QTY = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblTOT_WGT = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblPRFM_WGT = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblJROLLCNT = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblPRFM_ROLLCNT = new SmartDas.Components.MESLabel();
            this.label15 = new System.Windows.Forms.Label();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.label16 = new System.Windows.Forms.Label();
            this.lblBS_WGT = new SmartDas.Components.MESLabel();
            this.label17 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label18 = new System.Windows.Forms.Label();
            this.lblPRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
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
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO_N);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.txtWRK_ORDR_RMK_N);
            this.splitContainer1.Panel1.Controls.Add(this.txtWRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDateN);
            this.splitContainer1.Panel1.Controls.Add(this.butEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDateN);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTimeN);
            this.splitContainer1.Panel1.Controls.Add(this.label25);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.label24);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.label23);
            this.splitContainer1.Panel1.Controls.Add(this.lblWIDTH_N);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblDISPO_QTY_N);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_WGT_N);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_WGT_N);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.lblJROLLCNT_N);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_ROLLCNT_N);
            this.splitContainer1.Panel1.Controls.Add(this.label19);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR_N);
            this.splitContainer1.Panel1.Controls.Add(this.label20);
            this.splitContainer1.Panel1.Controls.Add(this.lblBS_WGT_N);
            this.splitContainer1.Panel1.Controls.Add(this.label21);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO_N);
            this.splitContainer1.Panel1.Controls.Add(this.label22);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT_N);
            this.splitContainer1.Panel1.Controls.Add(this.lblWIDTH);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblDISPO_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblJROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_ROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.label16);
            this.splitContainer1.Panel1.Controls.Add(this.lblBS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label17);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label18);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblWRK_ORDR_SEQNO_N
            // 
            this.lblWRK_ORDR_SEQNO_N.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_SEQNO_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_SEQNO_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_SEQNO_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_SEQNO_N.Location = new System.Drawing.Point(530, 449);
            this.lblWRK_ORDR_SEQNO_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO_N.MoveControl = null;
            this.lblWRK_ORDR_SEQNO_N.Name = "lblWRK_ORDR_SEQNO_N";
            this.lblWRK_ORDR_SEQNO_N.Size = new System.Drawing.Size(100, 45);
            this.lblWRK_ORDR_SEQNO_N.TabIndex = 267;
            this.lblWRK_ORDR_SEQNO_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO_N.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(530, 59);
            this.lblWRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO.MoveControl = null;
            this.lblWRK_ORDR_SEQNO.Name = "lblWRK_ORDR_SEQNO";
            this.lblWRK_ORDR_SEQNO.Size = new System.Drawing.Size(100, 45);
            this.lblWRK_ORDR_SEQNO.TabIndex = 266;
            this.lblWRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // txtWRK_ORDR_RMK_N
            // 
            this.txtWRK_ORDR_RMK_N.BackColor = System.Drawing.SystemColors.Info;
            this.txtWRK_ORDR_RMK_N.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtWRK_ORDR_RMK_N.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWRK_ORDR_RMK_N.Location = new System.Drawing.Point(10, 638);
            this.txtWRK_ORDR_RMK_N.Multiline = true;
            this.txtWRK_ORDR_RMK_N.Name = "txtWRK_ORDR_RMK_N";
            this.txtWRK_ORDR_RMK_N.ReadOnly = true;
            this.txtWRK_ORDR_RMK_N.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtWRK_ORDR_RMK_N.Size = new System.Drawing.Size(620, 140);
            this.txtWRK_ORDR_RMK_N.TabIndex = 265;
            // 
            // txtWRK_ORDR_RMK
            // 
            this.txtWRK_ORDR_RMK.BackColor = System.Drawing.SystemColors.Info;
            this.txtWRK_ORDR_RMK.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtWRK_ORDR_RMK.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWRK_ORDR_RMK.Location = new System.Drawing.Point(10, 248);
            this.txtWRK_ORDR_RMK.Multiline = true;
            this.txtWRK_ORDR_RMK.Name = "txtWRK_ORDR_RMK";
            this.txtWRK_ORDR_RMK.ReadOnly = true;
            this.txtWRK_ORDR_RMK.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtWRK_ORDR_RMK.Size = new System.Drawing.Size(620, 140);
            this.txtWRK_ORDR_RMK.TabIndex = 264;
            // 
            // butStartDateN
            // 
            this.butStartDateN.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDateN.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDateN.CausesValidation = false;
            this.butStartDateN.FlatAppearance.BorderSize = 0;
            this.butStartDateN.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDateN.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDateN.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDateN.Location = new System.Drawing.Point(1028, 689);
            this.butStartDateN.Name = "butStartDateN";
            this.butStartDateN.Size = new System.Drawing.Size(40, 40);
            this.butStartDateN.TabIndex = 263;
            this.butStartDateN.UseVisualStyleBackColor = false;
            this.butStartDateN.Click += new System.EventHandler(this.butStartDateN_Click);
            // 
            // butEndDate
            // 
            this.butEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butEndDate.CausesValidation = false;
            this.butEndDate.FlatAppearance.BorderSize = 0;
            this.butEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butEndDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butEndDate.Location = new System.Drawing.Point(1028, 346);
            this.butEndDate.Name = "butEndDate";
            this.butEndDate.Size = new System.Drawing.Size(40, 40);
            this.butEndDate.TabIndex = 262;
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
            this.butStartDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDate.Location = new System.Drawing.Point(1028, 298);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(40, 40);
            this.butStartDate.TabIndex = 261;
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butStartDate_Click);
            // 
            // dtpStartDateN
            // 
            this.dtpStartDateN.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDateN.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDateN.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDateN.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDateN.Location = new System.Drawing.Point(810, 686);
            this.dtpStartDateN.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpStartDateN.Name = "dtpStartDateN";
            this.dtpStartDateN.ShowUpDown = true;
            this.dtpStartDateN.Size = new System.Drawing.Size(260, 45);
            this.dtpStartDateN.TabIndex = 260;
            this.dtpStartDateN.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // lblStartTimeN
            // 
            this.lblStartTimeN.BackColor = System.Drawing.Color.White;
            this.lblStartTimeN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTimeN.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTimeN.ColorLabel = System.Drawing.Color.White;
            this.lblStartTimeN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTimeN.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTimeN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTimeN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTimeN.Location = new System.Drawing.Point(1080, 686);
            this.lblStartTimeN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTimeN.MoveControl = null;
            this.lblStartTimeN.Name = "lblStartTimeN";
            this.lblStartTimeN.Size = new System.Drawing.Size(180, 45);
            this.lblStartTimeN.TabIndex = 259;
            this.lblStartTimeN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStartTimeN.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTimeN.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label25
            // 
            this.label25.BackColor = System.Drawing.Color.Black;
            this.label25.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label25.ForeColor = System.Drawing.Color.White;
            this.label25.Location = new System.Drawing.Point(638, 686);
            this.label25.Name = "label25";
            this.label25.Size = new System.Drawing.Size(165, 45);
            this.label25.TabIndex = 258;
            this.label25.Text = "작업시작일시";
            this.label25.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(810, 344);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(260, 45);
            this.dtpEndDate.TabIndex = 257;
            this.dtpEndDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // dtpStartDate
            // 
            this.dtpStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDate.Location = new System.Drawing.Point(810, 296);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(260, 45);
            this.dtpStartDate.TabIndex = 256;
            this.dtpStartDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // lblEndTime
            // 
            this.lblEndTime.BackColor = System.Drawing.Color.White;
            this.lblEndTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEndTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblEndTime.ColorLabel = System.Drawing.Color.White;
            this.lblEndTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEndTime.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEndTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEndTime.Location = new System.Drawing.Point(1080, 344);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(180, 45);
            this.lblEndTime.TabIndex = 255;
            this.lblEndTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblEndTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label24
            // 
            this.label24.BackColor = System.Drawing.Color.Black;
            this.label24.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label24.ForeColor = System.Drawing.Color.White;
            this.label24.Location = new System.Drawing.Point(638, 344);
            this.label24.Name = "label24";
            this.label24.Size = new System.Drawing.Size(165, 45);
            this.label24.TabIndex = 253;
            this.label24.Text = "작업종료일시";
            this.label24.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblStartTime
            // 
            this.lblStartTime.BackColor = System.Drawing.Color.White;
            this.lblStartTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTime.ColorLabel = System.Drawing.Color.White;
            this.lblStartTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTime.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTime.Location = new System.Drawing.Point(1080, 296);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(180, 45);
            this.lblStartTime.TabIndex = 252;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label23
            // 
            this.label23.BackColor = System.Drawing.Color.Black;
            this.label23.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label23.ForeColor = System.Drawing.Color.White;
            this.label23.Location = new System.Drawing.Point(638, 296);
            this.label23.Name = "label23";
            this.label23.Size = new System.Drawing.Size(165, 45);
            this.label23.TabIndex = 250;
            this.label23.Text = "작업시작일시";
            this.label23.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWIDTH_N
            // 
            this.lblWIDTH_N.BackColor = System.Drawing.Color.LightGray;
            this.lblWIDTH_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWIDTH_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblWIDTH_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWIDTH_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWIDTH_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWIDTH_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWIDTH_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWIDTH_N.Location = new System.Drawing.Point(1040, 496);
            this.lblWIDTH_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWIDTH_N.MoveControl = null;
            this.lblWIDTH_N.Name = "lblWIDTH_N";
            this.lblWIDTH_N.Size = new System.Drawing.Size(220, 45);
            this.lblWIDTH_N.TabIndex = 249;
            this.lblWIDTH_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWIDTH_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(638, 638);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(165, 45);
            this.label10.TabIndex = 247;
            this.label10.Text = "폐품량";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblDISPO_QTY_N
            // 
            this.lblDISPO_QTY_N.BackColor = System.Drawing.Color.Black;
            this.lblDISPO_QTY_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblDISPO_QTY_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY_N.ColorLabel = System.Drawing.Color.Black;
            this.lblDISPO_QTY_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDISPO_QTY_N.ForeColor = System.Drawing.Color.Lime;
            this.lblDISPO_QTY_N.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblDISPO_QTY_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblDISPO_QTY_N.Location = new System.Drawing.Point(810, 638);
            this.lblDISPO_QTY_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDISPO_QTY_N.MoveControl = null;
            this.lblDISPO_QTY_N.Name = "lblDISPO_QTY_N";
            this.lblDISPO_QTY_N.Size = new System.Drawing.Size(450, 45);
            this.lblDISPO_QTY_N.TabIndex = 248;
            this.lblDISPO_QTY_N.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblDISPO_QTY_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Gray;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(8, 590);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(165, 45);
            this.label11.TabIndex = 241;
            this.label11.Text = "계획중량";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_WGT_N
            // 
            this.lblTOT_WGT_N.BackColor = System.Drawing.Color.LightGray;
            this.lblTOT_WGT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_WGT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_WGT_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblTOT_WGT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_WGT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_WGT_N.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblTOT_WGT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_WGT_N.Location = new System.Drawing.Point(180, 590);
            this.lblTOT_WGT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_WGT_N.MoveControl = null;
            this.lblTOT_WGT_N.Name = "lblTOT_WGT_N";
            this.lblTOT_WGT_N.Size = new System.Drawing.Size(450, 45);
            this.lblTOT_WGT_N.TabIndex = 242;
            this.lblTOT_WGT_N.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_WGT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Gray;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(638, 590);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(165, 45);
            this.label12.TabIndex = 243;
            this.label12.Text = "실적중량";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_WGT_N
            // 
            this.lblPRFM_WGT_N.BackColor = System.Drawing.Color.Black;
            this.lblPRFM_WGT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_WGT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT_N.ColorLabel = System.Drawing.Color.Black;
            this.lblPRFM_WGT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_WGT_N.ForeColor = System.Drawing.Color.Lime;
            this.lblPRFM_WGT_N.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblPRFM_WGT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_WGT_N.Location = new System.Drawing.Point(810, 590);
            this.lblPRFM_WGT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_WGT_N.MoveControl = null;
            this.lblPRFM_WGT_N.Name = "lblPRFM_WGT_N";
            this.lblPRFM_WGT_N.Size = new System.Drawing.Size(450, 45);
            this.lblPRFM_WGT_N.TabIndex = 244;
            this.lblPRFM_WGT_N.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_WGT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(8, 543);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(165, 45);
            this.label13.TabIndex = 237;
            this.label13.Text = "계획권치수";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblJROLLCNT_N
            // 
            this.lblJROLLCNT_N.BackColor = System.Drawing.Color.LightGray;
            this.lblJROLLCNT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblJROLLCNT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblJROLLCNT_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblJROLLCNT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblJROLLCNT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblJROLLCNT_N.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblJROLLCNT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblJROLLCNT_N.Location = new System.Drawing.Point(180, 543);
            this.lblJROLLCNT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblJROLLCNT_N.MoveControl = null;
            this.lblJROLLCNT_N.Name = "lblJROLLCNT_N";
            this.lblJROLLCNT_N.Size = new System.Drawing.Size(450, 45);
            this.lblJROLLCNT_N.TabIndex = 238;
            this.lblJROLLCNT_N.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblJROLLCNT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Gray;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(638, 543);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(165, 45);
            this.label14.TabIndex = 239;
            this.label14.Text = "실적권치수";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_ROLLCNT_N
            // 
            this.lblPRFM_ROLLCNT_N.BackColor = System.Drawing.Color.Black;
            this.lblPRFM_ROLLCNT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_ROLLCNT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_ROLLCNT_N.ColorLabel = System.Drawing.Color.Black;
            this.lblPRFM_ROLLCNT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_ROLLCNT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_ROLLCNT_N.ForeColor = System.Drawing.Color.Lime;
            this.lblPRFM_ROLLCNT_N.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblPRFM_ROLLCNT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_ROLLCNT_N.Location = new System.Drawing.Point(810, 543);
            this.lblPRFM_ROLLCNT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_ROLLCNT_N.MoveControl = null;
            this.lblPRFM_ROLLCNT_N.Name = "lblPRFM_ROLLCNT_N";
            this.lblPRFM_ROLLCNT_N.Size = new System.Drawing.Size(450, 45);
            this.lblPRFM_ROLLCNT_N.TabIndex = 240;
            this.lblPRFM_ROLLCNT_N.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_ROLLCNT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label19
            // 
            this.label19.BackColor = System.Drawing.Color.Gray;
            this.label19.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label19.ForeColor = System.Drawing.Color.White;
            this.label19.Location = new System.Drawing.Point(8, 496);
            this.label19.Name = "label19";
            this.label19.Size = new System.Drawing.Size(165, 45);
            this.label19.TabIndex = 233;
            this.label19.Text = "자재코드";
            this.label19.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblMATNR_N
            // 
            this.lblMATNR_N.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR_N.Location = new System.Drawing.Point(180, 496);
            this.lblMATNR_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR_N.MoveControl = null;
            this.lblMATNR_N.Name = "lblMATNR_N";
            this.lblMATNR_N.Size = new System.Drawing.Size(450, 45);
            this.lblMATNR_N.TabIndex = 234;
            this.lblMATNR_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label20
            // 
            this.label20.BackColor = System.Drawing.Color.Gray;
            this.label20.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label20.ForeColor = System.Drawing.Color.White;
            this.label20.Location = new System.Drawing.Point(638, 496);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(165, 45);
            this.label20.TabIndex = 235;
            this.label20.Text = "평량/지폭";
            this.label20.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblBS_WGT_N
            // 
            this.lblBS_WGT_N.BackColor = System.Drawing.Color.LightGray;
            this.lblBS_WGT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBS_WGT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblBS_WGT_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBS_WGT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBS_WGT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBS_WGT_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBS_WGT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBS_WGT_N.Location = new System.Drawing.Point(810, 496);
            this.lblBS_WGT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBS_WGT_N.MoveControl = null;
            this.lblBS_WGT_N.Name = "lblBS_WGT_N";
            this.lblBS_WGT_N.Size = new System.Drawing.Size(220, 45);
            this.lblBS_WGT_N.TabIndex = 236;
            this.lblBS_WGT_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblBS_WGT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label21
            // 
            this.label21.BackColor = System.Drawing.Color.Gray;
            this.label21.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label21.ForeColor = System.Drawing.Color.White;
            this.label21.Location = new System.Drawing.Point(8, 449);
            this.label21.Name = "label21";
            this.label21.Size = new System.Drawing.Size(165, 45);
            this.label21.TabIndex = 229;
            this.label21.Text = "작업지시번호";
            this.label21.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_NO_N
            // 
            this.lblWRK_ORDR_NO_N.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_NO_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_NO_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_NO_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_NO_N.Location = new System.Drawing.Point(180, 449);
            this.lblWRK_ORDR_NO_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_NO_N.MoveControl = null;
            this.lblWRK_ORDR_NO_N.Name = "lblWRK_ORDR_NO_N";
            this.lblWRK_ORDR_NO_N.Size = new System.Drawing.Size(350, 45);
            this.lblWRK_ORDR_NO_N.TabIndex = 230;
            this.lblWRK_ORDR_NO_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_NO_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label22
            // 
            this.label22.BackColor = System.Drawing.Color.Gray;
            this.label22.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label22.ForeColor = System.Drawing.Color.White;
            this.label22.Location = new System.Drawing.Point(638, 449);
            this.label22.Name = "label22";
            this.label22.Size = new System.Drawing.Size(165, 45);
            this.label22.TabIndex = 231;
            this.label22.Text = "생산지시일";
            this.label22.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRD_REQ_DT_N
            // 
            this.lblPRD_REQ_DT_N.BackColor = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT_N.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_REQ_DT_N.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT_N.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT_N.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT_N.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DT_N.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DT_N.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DT_N.Location = new System.Drawing.Point(810, 449);
            this.lblPRD_REQ_DT_N.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DT_N.MoveControl = null;
            this.lblPRD_REQ_DT_N.Name = "lblPRD_REQ_DT_N";
            this.lblPRD_REQ_DT_N.Size = new System.Drawing.Size(450, 45);
            this.lblPRD_REQ_DT_N.TabIndex = 232;
            this.lblPRD_REQ_DT_N.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_REQ_DT_N.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWIDTH
            // 
            this.lblWIDTH.BackColor = System.Drawing.Color.LightGray;
            this.lblWIDTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWIDTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblWIDTH.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWIDTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWIDTH.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWIDTH.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWIDTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWIDTH.Location = new System.Drawing.Point(1040, 106);
            this.lblWIDTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWIDTH.MoveControl = null;
            this.lblWIDTH.Name = "lblWIDTH";
            this.lblWIDTH.Size = new System.Drawing.Size(220, 45);
            this.lblWIDTH.TabIndex = 227;
            this.lblWIDTH.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWIDTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(638, 248);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(165, 45);
            this.label2.TabIndex = 225;
            this.label2.Text = "폐품량";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblDISPO_QTY
            // 
            this.lblDISPO_QTY.BackColor = System.Drawing.Color.Black;
            this.lblDISPO_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblDISPO_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY.ColorLabel = System.Drawing.Color.Black;
            this.lblDISPO_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDISPO_QTY.ForeColor = System.Drawing.Color.Lime;
            this.lblDISPO_QTY.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblDISPO_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblDISPO_QTY.Location = new System.Drawing.Point(810, 248);
            this.lblDISPO_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDISPO_QTY.MoveControl = null;
            this.lblDISPO_QTY.Name = "lblDISPO_QTY";
            this.lblDISPO_QTY.Size = new System.Drawing.Size(450, 45);
            this.lblDISPO_QTY.TabIndex = 226;
            this.lblDISPO_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblDISPO_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(8, 200);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(165, 45);
            this.label3.TabIndex = 219;
            this.label3.Text = "계획중량";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_WGT
            // 
            this.lblTOT_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblTOT_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblTOT_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_WGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_WGT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblTOT_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_WGT.Location = new System.Drawing.Point(180, 200);
            this.lblTOT_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_WGT.MoveControl = null;
            this.lblTOT_WGT.Name = "lblTOT_WGT";
            this.lblTOT_WGT.Size = new System.Drawing.Size(450, 45);
            this.lblTOT_WGT.TabIndex = 220;
            this.lblTOT_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(638, 200);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(165, 45);
            this.label4.TabIndex = 221;
            this.label4.Text = "실적중량";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_WGT
            // 
            this.lblPRFM_WGT.BackColor = System.Drawing.Color.Black;
            this.lblPRFM_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT.ColorLabel = System.Drawing.Color.Black;
            this.lblPRFM_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_WGT.ForeColor = System.Drawing.Color.Lime;
            this.lblPRFM_WGT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblPRFM_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_WGT.Location = new System.Drawing.Point(810, 200);
            this.lblPRFM_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_WGT.MoveControl = null;
            this.lblPRFM_WGT.Name = "lblPRFM_WGT";
            this.lblPRFM_WGT.Size = new System.Drawing.Size(450, 45);
            this.lblPRFM_WGT.TabIndex = 222;
            this.lblPRFM_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(8, 153);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(165, 45);
            this.label5.TabIndex = 215;
            this.label5.Text = "계획권치수";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblJROLLCNT
            // 
            this.lblJROLLCNT.BackColor = System.Drawing.Color.LightGray;
            this.lblJROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblJROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblJROLLCNT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblJROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblJROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblJROLLCNT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblJROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblJROLLCNT.Location = new System.Drawing.Point(180, 153);
            this.lblJROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblJROLLCNT.MoveControl = null;
            this.lblJROLLCNT.Name = "lblJROLLCNT";
            this.lblJROLLCNT.Size = new System.Drawing.Size(450, 45);
            this.lblJROLLCNT.TabIndex = 216;
            this.lblJROLLCNT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblJROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(638, 153);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(165, 45);
            this.label6.TabIndex = 217;
            this.label6.Text = "실적권치수";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_ROLLCNT
            // 
            this.lblPRFM_ROLLCNT.BackColor = System.Drawing.Color.Black;
            this.lblPRFM_ROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_ROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_ROLLCNT.ColorLabel = System.Drawing.Color.Black;
            this.lblPRFM_ROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_ROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_ROLLCNT.ForeColor = System.Drawing.Color.Lime;
            this.lblPRFM_ROLLCNT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblPRFM_ROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_ROLLCNT.Location = new System.Drawing.Point(810, 153);
            this.lblPRFM_ROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_ROLLCNT.MoveControl = null;
            this.lblPRFM_ROLLCNT.Name = "lblPRFM_ROLLCNT";
            this.lblPRFM_ROLLCNT.Size = new System.Drawing.Size(450, 45);
            this.lblPRFM_ROLLCNT.TabIndex = 218;
            this.lblPRFM_ROLLCNT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_ROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Gray;
            this.label15.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(8, 106);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(165, 45);
            this.label15.TabIndex = 211;
            this.label15.Text = "자재코드";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblMATNR.Location = new System.Drawing.Point(180, 106);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(450, 45);
            this.lblMATNR.TabIndex = 212;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label16
            // 
            this.label16.BackColor = System.Drawing.Color.Gray;
            this.label16.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label16.ForeColor = System.Drawing.Color.White;
            this.label16.Location = new System.Drawing.Point(638, 106);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(165, 45);
            this.label16.TabIndex = 213;
            this.label16.Text = "평량/지폭";
            this.label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblBS_WGT
            // 
            this.lblBS_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblBS_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBS_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblBS_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBS_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBS_WGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBS_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBS_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBS_WGT.Location = new System.Drawing.Point(810, 106);
            this.lblBS_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBS_WGT.MoveControl = null;
            this.lblBS_WGT.Name = "lblBS_WGT";
            this.lblBS_WGT.Size = new System.Drawing.Size(220, 45);
            this.lblBS_WGT.TabIndex = 214;
            this.lblBS_WGT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblBS_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label17
            // 
            this.label17.BackColor = System.Drawing.Color.Gray;
            this.label17.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label17.ForeColor = System.Drawing.Color.White;
            this.label17.Location = new System.Drawing.Point(8, 59);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(165, 45);
            this.label17.TabIndex = 207;
            this.label17.Text = "작업지시번호";
            this.label17.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(180, 59);
            this.lblWRK_ORDR_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_NO.MoveControl = null;
            this.lblWRK_ORDR_NO.Name = "lblWRK_ORDR_NO";
            this.lblWRK_ORDR_NO.Size = new System.Drawing.Size(350, 45);
            this.lblWRK_ORDR_NO.TabIndex = 208;
            this.lblWRK_ORDR_NO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label18
            // 
            this.label18.BackColor = System.Drawing.Color.Gray;
            this.label18.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label18.ForeColor = System.Drawing.Color.White;
            this.label18.Location = new System.Drawing.Point(638, 59);
            this.label18.Name = "label18";
            this.label18.Size = new System.Drawing.Size(165, 45);
            this.label18.TabIndex = 209;
            this.label18.Text = "생산요청일";
            this.label18.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblPRD_REQ_DT.Location = new System.Drawing.Point(810, 59);
            this.lblPRD_REQ_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DT.MoveControl = null;
            this.lblPRD_REQ_DT.Name = "lblPRD_REQ_DT";
            this.lblPRD_REQ_DT.Size = new System.Drawing.Size(450, 45);
            this.lblPRD_REQ_DT.TabIndex = 210;
            this.lblPRD_REQ_DT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_REQ_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Red;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(8, 395);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(1250, 50);
            this.label8.TabIndex = 143;
            this.label8.Text = "이후 작업지시";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Green;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(8, 6);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(1250, 50);
            this.label7.TabIndex = 142;
            this.label7.Text = "이전 작업지시";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // POP_WRK40
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK40";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK40_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private MESLabel lblWIDTH;
        private System.Windows.Forms.Label label2;
        private MESLabel lblDISPO_QTY;
        private System.Windows.Forms.Label label3;
        private MESLabel lblTOT_WGT;
        private System.Windows.Forms.Label label4;
        private MESLabel lblPRFM_WGT;
        private System.Windows.Forms.Label label5;
        private MESLabel lblJROLLCNT;
        private System.Windows.Forms.Label label6;
        private MESLabel lblPRFM_ROLLCNT;
        private System.Windows.Forms.Label label15;
        private MESLabel lblMATNR;
        private System.Windows.Forms.Label label16;
        private MESLabel lblBS_WGT;
        private System.Windows.Forms.Label label17;
        private MESLabel lblWRK_ORDR_NO;
        private System.Windows.Forms.Label label18;
        private MESLabel lblPRD_REQ_DT;
        private MESLabel lblWIDTH_N;
        private System.Windows.Forms.Label label10;
        private MESLabel lblDISPO_QTY_N;
        private System.Windows.Forms.Label label11;
        private MESLabel lblTOT_WGT_N;
        private System.Windows.Forms.Label label12;
        private MESLabel lblPRFM_WGT_N;
        private System.Windows.Forms.Label label13;
        private MESLabel lblJROLLCNT_N;
        private System.Windows.Forms.Label label14;
        private MESLabel lblPRFM_ROLLCNT_N;
        private System.Windows.Forms.Label label19;
        private MESLabel lblMATNR_N;
        private System.Windows.Forms.Label label20;
        private MESLabel lblBS_WGT_N;
        private System.Windows.Forms.Label label21;
        private MESLabel lblWRK_ORDR_NO_N;
        private System.Windows.Forms.Label label22;
        private MESLabel lblPRD_REQ_DT_N;
        private MESLabel lblEndTime;
        private System.Windows.Forms.Label label24;
        private MESLabel lblStartTime;
        private System.Windows.Forms.Label label23;
        private System.Windows.Forms.DateTimePicker dtpEndDate;
        private System.Windows.Forms.DateTimePicker dtpStartDate;
        private System.Windows.Forms.DateTimePicker dtpStartDateN;
        private MESLabel lblStartTimeN;
        private System.Windows.Forms.Label label25;
        private System.Windows.Forms.Button butStartDateN;
        private System.Windows.Forms.Button butEndDate;
        private System.Windows.Forms.Button butStartDate;
        private System.Windows.Forms.TextBox txtWRK_ORDR_RMK;
        private System.Windows.Forms.TextBox txtWRK_ORDR_RMK_N;
        private MESLabel lblWRK_ORDR_SEQNO_N;
        private MESLabel lblWRK_ORDR_SEQNO;

    }
}
