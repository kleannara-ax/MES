using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK05
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
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK05));
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblEditFlag = new SmartDas.Components.MESLabel();
            this.cboWorkTime = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.btnREQ_STR_DATE = new System.Windows.Forms.Button();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.label3 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.bGroup_Down = new SmartDas.Components.MESButton_Top();
            this.bGroup = new SmartDas.Components.ButtonBox();
            this.bGroup_Up = new SmartDas.Components.MESButton_Top();
            this.label4 = new System.Windows.Forms.Label();
            this.lblWorkerCnt = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.bWorker_Down = new SmartDas.Components.MESButton_Top();
            this.bWorker = new SmartDas.Components.ButtonBox();
            this.bWorker_Up = new SmartDas.Components.MESButton_Top();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.lblEndChkName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.cboWorkTime)).BeginInit();
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
            this.splitContainer1.Panel1.Controls.Add(this.lblEndChkName);
            this.splitContainer1.Panel1.Controls.Add(this.lblEditFlag);
            this.splitContainer1.Panel1.Controls.Add(this.cboWorkTime);
            this.splitContainer1.Panel1.Controls.Add(this.btnREQ_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblWorkerCnt);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.bWorker_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bWorker_Up);
            this.splitContainer1.Panel1.Controls.Add(this.bWorker);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 0;
            // 
            // lblEditFlag
            // 
            this.lblEditFlag.BackColor = System.Drawing.Color.White;
            this.lblEditFlag.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEditFlag.ColorContent = System.Drawing.Color.Transparent;
            this.lblEditFlag.ColorLabel = System.Drawing.Color.White;
            this.lblEditFlag.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEditFlag.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEditFlag.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEditFlag.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEditFlag.Location = new System.Drawing.Point(11, 78);
            this.lblEditFlag.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEditFlag.MoveControl = null;
            this.lblEditFlag.Name = "lblEditFlag";
            this.lblEditFlag.Size = new System.Drawing.Size(45, 45);
            this.lblEditFlag.TabIndex = 271;
            this.lblEditFlag.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblEditFlag.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEditFlag.Click += new System.EventHandler(this.lblEditFlag_Click);
            // 
            // cboWorkTime
            // 
            appearance2.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.cboWorkTime.Appearance = appearance2;
            this.cboWorkTime.AutoSize = false;
            this.cboWorkTime.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.cboWorkTime.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.cboWorkTime.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cboWorkTime.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.cboWorkTime.Location = new System.Drawing.Point(508, 11);
            this.cboWorkTime.MinimumSize = new System.Drawing.Size(0, 50);
            this.cboWorkTime.Name = "cboWorkTime";
            this.cboWorkTime.Size = new System.Drawing.Size(338, 50);
            this.cboWorkTime.TabIndex = 270;
            this.cboWorkTime.ValueChanged += new System.EventHandler(this.cboWorkTime_ValueChanged);
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
            this.btnREQ_STR_DATE.Location = new System.Drawing.Point(288, 14);
            this.btnREQ_STR_DATE.Name = "btnREQ_STR_DATE";
            this.btnREQ_STR_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnREQ_STR_DATE.TabIndex = 231;
            this.btnREQ_STR_DATE.Tag = "startDate";
            this.btnREQ_STR_DATE.UseVisualStyleBackColor = false;
            this.btnREQ_STR_DATE.Click += new System.EventHandler(this.btnREQ_STR_DATE_Click);
            // 
            // dtpPRD_STR_DATE
            // 
            this.dtpPRD_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(135, 12);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(200, 50);
            this.dtpPRD_STR_DATE.TabIndex = 230;
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(9, 12);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(120, 50);
            this.label3.TabIndex = 229;
            this.label3.Text = "작업일";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(9, 234);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(1150, 50);
            this.label5.TabIndex = 168;
            this.label5.Text = "대표자 선택";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.bGroup_Down.Location = new System.Drawing.Point(1218, 76);
            this.bGroup_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Down.Name = "bGroup_Down";
            this.bGroup_Down.ParentBox = null;
            this.bGroup_Down.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Down.TabIndex = 167;
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
            this.bGroup.ExTag = "-";
            this.bGroup.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bGroup.FontSize = 24F;
            this.bGroup.Location = new System.Drawing.Point(6, 129);
            this.bGroup.MarginIn = new System.Windows.Forms.Padding(3);
            this.bGroup.MarginOut = new System.Windows.Forms.Padding(3);
            this.bGroup.Name = "bGroup";
            this.bGroup.SelectCommand = null;
            this.bGroup.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bGroup.SelectProcedureName = null;
            this.bGroup.Size = new System.Drawing.Size(1260, 100);
            this.bGroup.TabIndex = 161;
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
            this.bGroup_Up.Location = new System.Drawing.Point(1162, 76);
            this.bGroup_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Up.Name = "bGroup_Up";
            this.bGroup_Up.ParentBox = null;
            this.bGroup_Up.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Up.TabIndex = 166;
            this.bGroup_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bGroup_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bGroup_Up.UseFlag = true;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(9, 76);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(1150, 50);
            this.label4.TabIndex = 165;
            this.label4.Text = "작업반 선택";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWorkerCnt
            // 
            this.lblWorkerCnt.BackColor = System.Drawing.Color.White;
            this.lblWorkerCnt.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWorkerCnt.ColorContent = System.Drawing.Color.Transparent;
            this.lblWorkerCnt.ColorLabel = System.Drawing.Color.White;
            this.lblWorkerCnt.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWorkerCnt.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWorkerCnt.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWorkerCnt.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWorkerCnt.Location = new System.Drawing.Point(1168, 12);
            this.lblWorkerCnt.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWorkerCnt.MoveControl = null;
            this.lblWorkerCnt.Name = "lblWorkerCnt";
            this.lblWorkerCnt.Size = new System.Drawing.Size(100, 50);
            this.lblWorkerCnt.TabIndex = 162;
            this.lblWorkerCnt.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWorkerCnt.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWorkerCnt.Click += new System.EventHandler(this.lblWorkerCnt_Click);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(350, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 121;
            this.label1.Text = "작업시간";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(1010, 11);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 155;
            this.label2.Text = "인원수";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // bWorker_Down
            // 
            this.bWorker_Down.AlarmColor = System.Drawing.Color.IndianRed;
            this.bWorker_Down.BackColor = System.Drawing.Color.Transparent;
            this.bWorker_Down.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bWorker_Down.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bWorker_Down.BackgroundImage")));
            this.bWorker_Down.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bWorker_Down.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bWorker_Down.ButtonPressed = false;
            this.bWorker_Down.ClickBackColor = System.Drawing.Color.Transparent;
            this.bWorker_Down.ExTag = null;
            this.bWorker_Down.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bWorker_Down.FontSize = 24F;
            this.bWorker_Down.LinkButtonBox = this.bWorker;
            this.bWorker_Down.LinkGrid = null;
            this.bWorker_Down.LinkMoveSize = 0;
            this.bWorker_Down.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bWorker_Down.Location = new System.Drawing.Point(1218, 234);
            this.bWorker_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bWorker_Down.Name = "bWorker_Down";
            this.bWorker_Down.ParentBox = null;
            this.bWorker_Down.Size = new System.Drawing.Size(50, 50);
            this.bWorker_Down.TabIndex = 154;
            this.bWorker_Down.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bWorker_Down.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bWorker_Down.UseFlag = true;
            // 
            // bWorker
            // 
            this.bWorker.BackColor = System.Drawing.Color.Transparent;
            this.bWorker.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bWorker.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bWorker.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bWorker.CountX = 1;
            this.bWorker.CountY = 1;
            this.bWorker.CurrentPage = 0;
            this.bWorker.ExTag = "-";
            this.bWorker.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bWorker.FontSize = 24F;
            this.bWorker.Location = new System.Drawing.Point(6, 287);
            this.bWorker.MarginIn = new System.Windows.Forms.Padding(3);
            this.bWorker.MarginOut = new System.Windows.Forms.Padding(3);
            this.bWorker.Name = "bWorker";
            this.bWorker.SelectCommand = null;
            this.bWorker.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bWorker.SelectProcedureName = null;
            this.bWorker.Size = new System.Drawing.Size(1260, 500);
            this.bWorker.TabIndex = 149;
            this.bWorker.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bWorker_buttonChangeEvent);
            // 
            // bWorker_Up
            // 
            this.bWorker_Up.AlarmColor = System.Drawing.Color.IndianRed;
            this.bWorker_Up.BackColor = System.Drawing.Color.Transparent;
            this.bWorker_Up.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bWorker_Up.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bWorker_Up.BackgroundImage")));
            this.bWorker_Up.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bWorker_Up.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bWorker_Up.ButtonPressed = false;
            this.bWorker_Up.ClickBackColor = System.Drawing.Color.Transparent;
            this.bWorker_Up.ExTag = null;
            this.bWorker_Up.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bWorker_Up.FontSize = 24F;
            this.bWorker_Up.LinkButtonBox = this.bWorker;
            this.bWorker_Up.LinkGrid = null;
            this.bWorker_Up.LinkMoveSize = 0;
            this.bWorker_Up.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bWorker_Up.Location = new System.Drawing.Point(1162, 234);
            this.bWorker_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bWorker_Up.Name = "bWorker_Up";
            this.bWorker_Up.ParentBox = null;
            this.bWorker_Up.Size = new System.Drawing.Size(50, 50);
            this.bWorker_Up.TabIndex = 153;
            this.bWorker_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bWorker_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bWorker_Up.UseFlag = true;
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
            this.bBox1.TabIndex = 65;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // lblEndChkName
            // 
            this.lblEndChkName.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.lblEndChkName.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndChkName.ForeColor = System.Drawing.SystemColors.ControlText;
            this.lblEndChkName.Location = new System.Drawing.Point(64, 81);
            this.lblEndChkName.Name = "lblEndChkName";
            this.lblEndChkName.Size = new System.Drawing.Size(120, 40);
            this.lblEndChkName.TabIndex = 272;
            this.lblEndChkName.Text = "작업반 변경";
            this.lblEndChkName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // POP_WRK05
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK05";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK05_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.cboWorkTime)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        protected MESButton_Top bWorker_Down;
        private ButtonBox bWorker;
        protected MESButton_Top bWorker_Up;
        private ButtonBox bBox1;
        private System.Windows.Forms.Label label1;
        private ButtonBox bGroup;
        private System.Windows.Forms.Label label5;
        protected MESButton_Top bGroup_Down;
        protected MESButton_Top bGroup_Up;
        private System.Windows.Forms.Label label4;
        private MESLabel lblWorkerCnt;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnREQ_STR_DATE;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.Label label3;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor cboWorkTime;
        private MESLabel lblEditFlag;
        private System.Windows.Forms.Label lblEndChkName;



    }
}
