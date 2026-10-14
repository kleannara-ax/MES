using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK53
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK43));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblWIDTH = new SmartDas.Components.MESLabel();
            this.lblPRFM_DT = new SmartDas.Components.MESLabel();
            this.lblDISPO_NAME = new SmartDas.Components.MESLabel();
            this.label13 = new System.Windows.Forms.Label();
            this.butEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.lblBS_WGT = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblDISPO_QTY = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.label34 = new System.Windows.Forms.Label();
            this.dtpEndDate = new System.Windows.Forms.DateTimePicker();
            this.bItem_Down = new SmartDas.Components.MESButton_Top();
            this.bItem = new SmartDas.Components.ButtonBox();
            this.bItem_Up = new SmartDas.Components.MESButton_Top();
            this.label12 = new System.Windows.Forms.Label();
            this.bGroup_Down = new SmartDas.Components.MESButton_Top();
            this.bGroup = new SmartDas.Components.ButtonBox();
            this.bGroup_Up = new SmartDas.Components.MESButton_Top();
            this.label11 = new System.Windows.Forms.Label();
            this.lblTM = new SmartDas.Components.MESLabel();
            this.label10 = new System.Windows.Forms.Label();
            this.lblRSPEED = new SmartDas.Components.MESLabel();
            this.label9 = new System.Windows.Forms.Label();
            this.lblPRFM_WGT = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.lblROLLCNT = new SmartDas.Components.MESLabel();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.lb_RMK = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWGT = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.dtpStartDate = new System.Windows.Forms.DateTimePicker();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
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
            this.btnRightPage.LinkButtonBox = this.bItem;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkButtonBox = this.bItem;
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
            this.splitContainer1.Panel1.Controls.Add(this.lblWIDTH);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_DT);
            this.splitContainer1.Panel1.Controls.Add(this.lblDISPO_NAME);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.butEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblBS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblDISPO_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.label34);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblTM);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblRSPEED);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.lblROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lb_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWGT);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.bItem);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblWIDTH
            // 
            this.lblWIDTH.BackColor = System.Drawing.Color.LightGray;
            this.lblWIDTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWIDTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblWIDTH.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWIDTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWIDTH.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWIDTH.ForeColor = System.Drawing.SystemColors.ControlText;
            this.lblWIDTH.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWIDTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWIDTH.Location = new System.Drawing.Point(297, 111);
            this.lblWIDTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWIDTH.MoveControl = null;
            this.lblWIDTH.Name = "lblWIDTH";
            this.lblWIDTH.Size = new System.Drawing.Size(120, 50);
            this.lblWIDTH.TabIndex = 275;
            this.lblWIDTH.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWIDTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPRFM_DT
            // 
            this.lblPRFM_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFM_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFM_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_DT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_DT.Location = new System.Drawing.Point(1016, 6);
            this.lblPRFM_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_DT.MoveControl = null;
            this.lblPRFM_DT.Name = "lblPRFM_DT";
            this.lblPRFM_DT.Size = new System.Drawing.Size(250, 50);
            this.lblPRFM_DT.TabIndex = 274;
            this.lblPRFM_DT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRFM_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblDISPO_NAME
            // 
            this.lblDISPO_NAME.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.lblDISPO_NAME.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblDISPO_NAME.ColorContent = System.Drawing.Color.Transparent;
            this.lblDISPO_NAME.ColorLabel = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.lblDISPO_NAME.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblDISPO_NAME.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDISPO_NAME.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblDISPO_NAME.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblDISPO_NAME.Location = new System.Drawing.Point(775, 362);
            this.lblDISPO_NAME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDISPO_NAME.MoveControl = null;
            this.lblDISPO_NAME.Name = "lblDISPO_NAME";
            this.lblDISPO_NAME.Size = new System.Drawing.Size(380, 50);
            this.lblDISPO_NAME.TabIndex = 273;
            this.lblDISPO_NAME.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblDISPO_NAME.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Black;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(619, 362);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(150, 50);
            this.label13.TabIndex = 272;
            this.label13.Text = "선택항목";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.butEndDate.Location = new System.Drawing.Point(707, 8);
            this.butEndDate.Name = "butEndDate";
            this.butEndDate.Size = new System.Drawing.Size(46, 46);
            this.butEndDate.TabIndex = 269;
            this.butEndDate.Tag = "endDate";
            this.butEndDate.UseVisualStyleBackColor = false;
            this.butEndDate.Click += new System.EventHandler(this.butDate_Click);
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
            this.butStartDate.Location = new System.Drawing.Point(339, 8);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(46, 46);
            this.butStartDate.TabIndex = 268;
            this.butStartDate.Tag = "startDate";
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butDate_Click);
            // 
            // lblBS_WGT
            // 
            this.lblBS_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblBS_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBS_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblBS_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBS_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBS_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBS_WGT.ForeColor = System.Drawing.SystemColors.ControlText;
            this.lblBS_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBS_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBS_WGT.Location = new System.Drawing.Point(167, 111);
            this.lblBS_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBS_WGT.MoveControl = null;
            this.lblBS_WGT.Name = "lblBS_WGT";
            this.lblBS_WGT.Size = new System.Drawing.Size(120, 50);
            this.lblBS_WGT.TabIndex = 267;
            this.lblBS_WGT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblBS_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(860, 164);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 266;
            this.label3.Text = "폐품량";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblDISPO_QTY
            // 
            this.lblDISPO_QTY.BackColor = System.Drawing.Color.Black;
            this.lblDISPO_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblDISPO_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY.ColorLabel = System.Drawing.Color.Black;
            this.lblDISPO_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblDISPO_QTY.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDISPO_QTY.ForeColor = System.Drawing.Color.Lime;
            this.lblDISPO_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblDISPO_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblDISPO_QTY.Location = new System.Drawing.Point(1016, 164);
            this.lblDISPO_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDISPO_QTY.MoveControl = null;
            this.lblDISPO_QTY.Name = "lblDISPO_QTY";
            this.lblDISPO_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblDISPO_QTY.TabIndex = 265;
            this.lblDISPO_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblDISPO_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 111);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 264;
            this.label1.Text = "평량/지폭";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label34
            // 
            this.label34.AutoSize = true;
            this.label34.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label34.Location = new System.Drawing.Point(491, 19);
            this.label34.Name = "label34";
            this.label34.Size = new System.Drawing.Size(25, 25);
            this.label34.TabIndex = 263;
            this.label34.Text = "~";
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(535, 6);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(220, 50);
            this.dtpEndDate.TabIndex = 206;
            this.dtpEndDate.ValueChanged += new System.EventHandler(this.dtpDate_ValueChanged);
            this.dtpEndDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // bItem_Down
            // 
            this.bItem_Down.AlarmColor = System.Drawing.Color.IndianRed;
            this.bItem_Down.BackColor = System.Drawing.Color.Transparent;
            this.bItem_Down.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bItem_Down.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bItem_Down.BackgroundImage")));
            this.bItem_Down.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bItem_Down.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bItem_Down.ButtonPressed = false;
            this.bItem_Down.ClickBackColor = System.Drawing.Color.Transparent;
            this.bItem_Down.ExTag = null;
            this.bItem_Down.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bItem_Down.FontSize = 24F;
            this.bItem_Down.LinkButtonBox = this.bItem;
            this.bItem_Down.LinkGrid = null;
            this.bItem_Down.LinkMoveSize = 0;
            this.bItem_Down.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bItem_Down.Location = new System.Drawing.Point(1216, 361);
            this.bItem_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bItem_Down.Name = "bItem_Down";
            this.bItem_Down.ParentBox = null;
            this.bItem_Down.Size = new System.Drawing.Size(50, 50);
            this.bItem_Down.TabIndex = 205;
            this.bItem_Down.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bItem_Down.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bItem_Down.UseFlag = true;
            // 
            // bItem
            // 
            this.bItem.BackColor = System.Drawing.Color.Transparent;
            this.bItem.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bItem.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bItem.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bItem.CountX = 1;
            this.bItem.CountY = 1;
            this.bItem.CurrentPage = 0;
            this.bItem.ExTag = "";
            this.bItem.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.bItem.FontSize = 14F;
            this.bItem.Location = new System.Drawing.Point(11, 416);
            this.bItem.MarginIn = new System.Windows.Forms.Padding(3);
            this.bItem.MarginOut = new System.Windows.Forms.Padding(3);
            this.bItem.Name = "bItem";
            this.bItem.SelectCommand = null;
            this.bItem.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bItem.SelectProcedureName = null;
            this.bItem.Size = new System.Drawing.Size(1255, 370);
            this.bItem.TabIndex = 176;
            this.bItem.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bItem_buttonChangeEvent);
            // 
            // bItem_Up
            // 
            this.bItem_Up.AlarmColor = System.Drawing.Color.IndianRed;
            this.bItem_Up.BackColor = System.Drawing.Color.Transparent;
            this.bItem_Up.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bItem_Up.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bItem_Up.BackgroundImage")));
            this.bItem_Up.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bItem_Up.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bItem_Up.ButtonPressed = false;
            this.bItem_Up.ClickBackColor = System.Drawing.Color.Transparent;
            this.bItem_Up.ExTag = null;
            this.bItem_Up.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bItem_Up.FontSize = 24F;
            this.bItem_Up.LinkButtonBox = this.bItem;
            this.bItem_Up.LinkGrid = null;
            this.bItem_Up.LinkMoveSize = 0;
            this.bItem_Up.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bItem_Up.Location = new System.Drawing.Point(1160, 361);
            this.bItem_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bItem_Up.Name = "bItem_Up";
            this.bItem_Up.ParentBox = null;
            this.bItem_Up.Size = new System.Drawing.Size(50, 50);
            this.bItem_Up.TabIndex = 204;
            this.bItem_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bItem_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bItem_Up.UseFlag = true;
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.Black;
            this.label12.Location = new System.Drawing.Point(11, 361);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(600, 50);
            this.label12.TabIndex = 203;
            this.label12.Text = "폐품 항목";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // bGroup_Down
            // 
            this.bGroup_Down.AlarmColor = System.Drawing.Color.IndianRed;
            this.bGroup_Down.BackColor = System.Drawing.Color.Transparent;
            this.bGroup_Down.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bGroup_Down.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bGroup_Down.BackgroundImage")));
            this.bGroup_Down.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bGroup_Down.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bGroup_Down.ButtonPressed = false;
            this.bGroup_Down.ClickBackColor = System.Drawing.Color.Transparent;
            this.bGroup_Down.ExTag = null;
            this.bGroup_Down.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bGroup_Down.FontSize = 24F;
            this.bGroup_Down.LinkButtonBox = this.bGroup;
            this.bGroup_Down.LinkGrid = null;
            this.bGroup_Down.LinkMoveSize = 0;
            this.bGroup_Down.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bGroup_Down.Location = new System.Drawing.Point(1216, 220);
            this.bGroup_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Down.Name = "bGroup_Down";
            this.bGroup_Down.ParentBox = null;
            this.bGroup_Down.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Down.TabIndex = 202;
            this.bGroup_Down.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bGroup_Down.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bGroup_Down.UseFlag = true;
            // 
            // bGroup
            // 
            this.bGroup.BackColor = System.Drawing.Color.Transparent;
            this.bGroup.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bGroup.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bGroup.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bGroup.CountX = 1;
            this.bGroup.CountY = 1;
            this.bGroup.CurrentPage = 0;
            this.bGroup.ExTag = "";
            this.bGroup.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.bGroup.FontSize = 14F;
            this.bGroup.Location = new System.Drawing.Point(11, 273);
            this.bGroup.MarginIn = new System.Windows.Forms.Padding(3);
            this.bGroup.MarginOut = new System.Windows.Forms.Padding(3);
            this.bGroup.Name = "bGroup";
            this.bGroup.SelectCommand = null;
            this.bGroup.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bGroup.SelectProcedureName = null;
            this.bGroup.Size = new System.Drawing.Size(1255, 80);
            this.bGroup.TabIndex = 181;
            this.bGroup.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bGroup_buttonChangeEvent);
            // 
            // bGroup_Up
            // 
            this.bGroup_Up.AlarmColor = System.Drawing.Color.IndianRed;
            this.bGroup_Up.BackColor = System.Drawing.Color.Transparent;
            this.bGroup_Up.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bGroup_Up.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bGroup_Up.BackgroundImage")));
            this.bGroup_Up.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bGroup_Up.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bGroup_Up.ButtonPressed = false;
            this.bGroup_Up.ClickBackColor = System.Drawing.Color.Transparent;
            this.bGroup_Up.ExTag = null;
            this.bGroup_Up.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bGroup_Up.FontSize = 24F;
            this.bGroup_Up.LinkButtonBox = this.bGroup;
            this.bGroup_Up.LinkGrid = null;
            this.bGroup_Up.LinkMoveSize = 0;
            this.bGroup_Up.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bGroup_Up.Location = new System.Drawing.Point(1160, 220);
            this.bGroup_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Up.Name = "bGroup_Up";
            this.bGroup_Up.ParentBox = null;
            this.bGroup_Up.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Up.TabIndex = 201;
            this.bGroup_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bGroup_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bGroup_Up.UseFlag = true;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.Black;
            this.label11.Location = new System.Drawing.Point(11, 220);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(1140, 50);
            this.label11.TabIndex = 200;
            this.label11.Text = "폐품 그룹";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblTM
            // 
            this.lblTM.BackColor = System.Drawing.Color.LightGray;
            this.lblTM.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTM.ColorContent = System.Drawing.Color.Transparent;
            this.lblTM.ColorLabel = System.Drawing.Color.LightGray;
            this.lblTM.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTM.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTM.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTM.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTM.Location = new System.Drawing.Point(1016, 59);
            this.lblTM.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTM.MoveControl = null;
            this.lblTM.Name = "lblTM";
            this.lblTM.Size = new System.Drawing.Size(250, 50);
            this.lblTM.TabIndex = 199;
            this.lblTM.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTM.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Black;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(860, 59);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(150, 50);
            this.label10.TabIndex = 198;
            this.label10.Text = "가동시간(분)";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblRSPEED
            // 
            this.lblRSPEED.BackColor = System.Drawing.Color.LightGray;
            this.lblRSPEED.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblRSPEED.ColorContent = System.Drawing.Color.Transparent;
            this.lblRSPEED.ColorLabel = System.Drawing.Color.LightGray;
            this.lblRSPEED.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblRSPEED.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblRSPEED.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblRSPEED.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblRSPEED.Location = new System.Drawing.Point(592, 59);
            this.lblRSPEED.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblRSPEED.MoveControl = null;
            this.lblRSPEED.Name = "lblRSPEED";
            this.lblRSPEED.Size = new System.Drawing.Size(250, 50);
            this.lblRSPEED.TabIndex = 197;
            this.lblRSPEED.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblRSPEED.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Black;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(436, 59);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(150, 50);
            this.label9.TabIndex = 196;
            this.label9.Text = "선속(M/분)";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_WGT
            // 
            this.lblPRFM_WGT.BackColor = System.Drawing.Color.Black;
            this.lblPRFM_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT.ColorLabel = System.Drawing.Color.Black;
            this.lblPRFM_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_WGT.ForeColor = System.Drawing.Color.Lime;
            this.lblPRFM_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_WGT.Location = new System.Drawing.Point(1016, 111);
            this.lblPRFM_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_WGT.MoveControl = null;
            this.lblPRFM_WGT.Name = "lblPRFM_WGT";
            this.lblPRFM_WGT.Size = new System.Drawing.Size(250, 50);
            this.lblPRFM_WGT.TabIndex = 195;
            this.lblPRFM_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Gray;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(860, 111);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(150, 50);
            this.label8.TabIndex = 194;
            this.label8.Text = "실적중량";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblROLLCNT
            // 
            this.lblROLLCNT.BackColor = System.Drawing.Color.LightGray;
            this.lblROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblROLLCNT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblROLLCNT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblROLLCNT.Location = new System.Drawing.Point(592, 111);
            this.lblROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblROLLCNT.MoveControl = null;
            this.lblROLLCNT.Name = "lblROLLCNT";
            this.lblROLLCNT.Size = new System.Drawing.Size(250, 50);
            this.lblROLLCNT.TabIndex = 193;
            this.lblROLLCNT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Black;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(11, 59);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(150, 50);
            this.label7.TabIndex = 192;
            this.label7.Text = "중량(Kg)";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Black;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(860, 6);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(150, 50);
            this.label6.TabIndex = 190;
            this.label6.Text = "생산실적일자";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lb_RMK
            // 
            this.lb_RMK.BackColor = System.Drawing.Color.White;
            this.lb_RMK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lb_RMK.ColorContent = System.Drawing.Color.Transparent;
            this.lb_RMK.ColorLabel = System.Drawing.Color.White;
            this.lb_RMK.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lb_RMK.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lb_RMK.LabelPadding = new System.Drawing.Size(0, 0);
            this.lb_RMK.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lb_RMK.Location = new System.Drawing.Point(167, 164);
            this.lb_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lb_RMK.MoveControl = null;
            this.lb_RMK.Name = "lb_RMK";
            this.lb_RMK.Size = new System.Drawing.Size(675, 50);
            this.lb_RMK.TabIndex = 189;
            this.lb_RMK.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lb_RMK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lb_RMK.Click += new System.EventHandler(this.lblRemark_Click);
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Black;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(11, 164);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(150, 50);
            this.label5.TabIndex = 188;
            this.label5.Text = "비고";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWGT
            // 
            this.lblWGT.BackColor = System.Drawing.Color.White;
            this.lblWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWGT.ColorLabel = System.Drawing.Color.White;
            this.lblWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWGT.Location = new System.Drawing.Point(167, 59);
            this.lblWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWGT.MoveControl = null;
            this.lblWGT.Name = "lblWGT";
            this.lblWGT.Size = new System.Drawing.Size(250, 50);
            this.lblWGT.TabIndex = 187;
            this.lblWGT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWGT.Click += new System.EventHandler(this.lblLength_Click);
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Black;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(436, 111);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(150, 50);
            this.label4.TabIndex = 186;
            this.label4.Text = "권치수(M)";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblEndTime.Location = new System.Drawing.Point(763, 6);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(80, 50);
            this.lblEndTime.TabIndex = 185;
            this.lblEndTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblEndTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpStartDate
            // 
            this.dtpStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDate.Location = new System.Drawing.Point(167, 6);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(220, 50);
            this.dtpStartDate.TabIndex = 180;
            this.dtpStartDate.ValueChanged += new System.EventHandler(this.dtpDate_ValueChanged);
            this.dtpStartDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
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
            this.lblStartTime.Location = new System.Drawing.Point(395, 6);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(80, 50);
            this.lblStartTime.TabIndex = 175;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Black;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(11, 6);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 179;
            this.label2.Text = "작업 일시";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // POP_WRK43
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK43";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK53_Load);
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
        private MESLabel lblTM;
        private System.Windows.Forms.Label label10;
        private MESLabel lblRSPEED;
        private System.Windows.Forms.Label label9;
        private MESLabel lblPRFM_WGT;
        private System.Windows.Forms.Label label8;
        private MESLabel lblROLLCNT;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private MESLabel lb_RMK;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWGT;
        private System.Windows.Forms.Label label4;
        private MESLabel lblEndTime;
        private ButtonBox bItem;
        private ButtonBox bGroup;
        private System.Windows.Forms.DateTimePicker dtpStartDate;
        private MESLabel lblStartTime;
        private System.Windows.Forms.Label label2;
        protected MESButton_Top bItem_Down;
        protected MESButton_Top bItem_Up;
        private System.Windows.Forms.Label label12;
        protected MESButton_Top bGroup_Down;
        protected MESButton_Top bGroup_Up;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.DateTimePicker dtpEndDate;
        private MESLabel lblBS_WGT;
        private System.Windows.Forms.Label label3;
        private MESLabel lblDISPO_QTY;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label34;
        private System.Windows.Forms.Button butEndDate;
        private System.Windows.Forms.Button butStartDate;
        private MESLabel lblDISPO_NAME;
        private System.Windows.Forms.Label label13;
        private MESLabel lblPRFM_DT;
        private MESLabel lblWIDTH;

    }
}
