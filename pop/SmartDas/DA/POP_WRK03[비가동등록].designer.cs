using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK03
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK03));
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.bGroup_Down = new SmartDas.Components.MESButton_Top();
            this.bGroup = new SmartDas.Components.ButtonBox();
            this.bGroup_Up = new SmartDas.Components.MESButton_Top();
            this.label11 = new System.Windows.Forms.Label();
            this.txtRemark = new System.Windows.Forms.TextBox();
            this.btnEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.dtpEndDate = new System.Windows.Forms.DateTimePicker();
            this.label2 = new System.Windows.Forms.Label();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.dtpStartDate = new System.Windows.Forms.DateTimePicker();
            this.label7 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.lblNonActTime = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.bItem_Down = new SmartDas.Components.MESButton_Top();
            this.bItem = new SmartDas.Components.ButtonBox();
            this.bItem_Up = new SmartDas.Components.MESButton_Top();
            this.bBox1 = new SmartDas.Components.ButtonBox();
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
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup);
            this.splitContainer1.Panel1.Controls.Add(this.txtRemark);
            this.splitContainer1.Panel1.Controls.Add(this.btnEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.lblNonActTime);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Up);
            this.splitContainer1.Panel1.Controls.Add(this.bItem);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 0;
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
            this.bGroup_Down.Location = new System.Drawing.Point(1215, 125);
            this.bGroup_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Down.Name = "bGroup_Down";
            this.bGroup_Down.ParentBox = null;
            this.bGroup_Down.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Down.TabIndex = 206;
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
            this.bGroup.Location = new System.Drawing.Point(6, 178);
            this.bGroup.MarginIn = new System.Windows.Forms.Padding(3);
            this.bGroup.MarginOut = new System.Windows.Forms.Padding(3);
            this.bGroup.Name = "bGroup";
            this.bGroup.SelectCommand = null;
            this.bGroup.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bGroup.SelectProcedureName = null;
            this.bGroup.Size = new System.Drawing.Size(1260, 174);
            this.bGroup.TabIndex = 203;
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
            this.bGroup_Up.Location = new System.Drawing.Point(1159, 125);
            this.bGroup_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bGroup_Up.Name = "bGroup_Up";
            this.bGroup_Up.ParentBox = null;
            this.bGroup_Up.Size = new System.Drawing.Size(50, 50);
            this.bGroup_Up.TabIndex = 205;
            this.bGroup_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bGroup_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bGroup_Up.UseFlag = true;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.Black;
            this.label11.Location = new System.Drawing.Point(6, 125);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(1150, 50);
            this.label11.TabIndex = 204;
            this.label11.Text = "운전상태";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // txtRemark
            // 
            this.txtRemark.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtRemark.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtRemark.Location = new System.Drawing.Point(173, 67);
            this.txtRemark.MinimumSize = new System.Drawing.Size(520, 50);
            this.txtRemark.Name = "txtRemark";
            this.txtRemark.Size = new System.Drawing.Size(1085, 50);
            this.txtRemark.TabIndex = 179;
            // 
            // btnEndDate
            // 
            this.btnEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnEndDate.CausesValidation = false;
            this.btnEndDate.FlatAppearance.BorderSize = 0;
            this.btnEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnEndDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnEndDate.Location = new System.Drawing.Point(798, 10);
            this.btnEndDate.Name = "btnEndDate";
            this.btnEndDate.Size = new System.Drawing.Size(46, 46);
            this.btnEndDate.TabIndex = 177;
            this.btnEndDate.Tag = "endDate";
            this.btnEndDate.UseVisualStyleBackColor = false;
            this.btnEndDate.Click += new System.EventHandler(this.btnWorkDate_Click);
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
            this.butStartDate.Location = new System.Drawing.Point(325, 11);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(46, 46);
            this.butStartDate.TabIndex = 176;
            this.butStartDate.Tag = "startDate";
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.btnWorkDate_Click);
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(646, 8);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(200, 50);
            this.dtpEndDate.TabIndex = 175;
            this.dtpEndDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(487, 8);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 174;
            this.label2.Text = "종료일시";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblEndTime.Location = new System.Drawing.Point(852, 8);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(100, 50);
            this.lblEndTime.TabIndex = 173;
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
            this.dtpStartDate.Location = new System.Drawing.Point(173, 9);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(200, 50);
            this.dtpStartDate.TabIndex = 172;
            this.dtpStartDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(14, 9);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(150, 50);
            this.label7.TabIndex = 171;
            this.label7.Text = "시작일시";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.Black;
            this.label5.Location = new System.Drawing.Point(6, 355);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(1150, 50);
            this.label5.TabIndex = 168;
            this.label5.Text = "비가동 항목";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(14, 67);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 163;
            this.label3.Text = "비고";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblStartTime.Location = new System.Drawing.Point(379, 9);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(100, 50);
            this.lblStartTime.TabIndex = 162;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // lblNonActTime
            // 
            this.lblNonActTime.BackColor = System.Drawing.Color.White;
            this.lblNonActTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblNonActTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblNonActTime.ColorLabel = System.Drawing.Color.White;
            this.lblNonActTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblNonActTime.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblNonActTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblNonActTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblNonActTime.Location = new System.Drawing.Point(1119, 8);
            this.lblNonActTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblNonActTime.MoveControl = null;
            this.lblNonActTime.Name = "lblNonActTime";
            this.lblNonActTime.Size = new System.Drawing.Size(140, 50);
            this.lblNonActTime.TabIndex = 123;
            this.lblNonActTime.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblNonActTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(960, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 121;
            this.label1.Text = "비가동시간(분)";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.bItem_Down.Location = new System.Drawing.Point(1215, 355);
            this.bItem_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bItem_Down.Name = "bItem_Down";
            this.bItem_Down.ParentBox = null;
            this.bItem_Down.Size = new System.Drawing.Size(50, 50);
            this.bItem_Down.TabIndex = 154;
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
            this.bItem.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bItem.FontSize = 24F;
            this.bItem.Location = new System.Drawing.Point(6, 409);
            this.bItem.MarginIn = new System.Windows.Forms.Padding(3);
            this.bItem.MarginOut = new System.Windows.Forms.Padding(3);
            this.bItem.Name = "bItem";
            this.bItem.SelectCommand = null;
            this.bItem.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bItem.SelectProcedureName = null;
            this.bItem.Size = new System.Drawing.Size(1260, 372);
            this.bItem.TabIndex = 149;
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
            this.bItem_Up.Location = new System.Drawing.Point(1159, 355);
            this.bItem_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bItem_Up.Name = "bItem_Up";
            this.bItem_Up.ParentBox = null;
            this.bItem_Up.Size = new System.Drawing.Size(50, 50);
            this.bItem_Up.TabIndex = 153;
            this.bItem_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bItem_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bItem_Up.UseFlag = true;
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
            this.bBox1.TabIndex = 65;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // POP_WRK03
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK03";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK03_Load);
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
        protected MESButton_Top bItem_Down;
        private ButtonBox bItem;
        protected MESButton_Top bItem_Up;
        private ButtonBox bBox1;
        private MESLabel lblNonActTime;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label3;
        private MESLabel lblStartTime;
        private System.Windows.Forms.DateTimePicker dtpEndDate;
        private System.Windows.Forms.Label label2;
        private MESLabel lblEndTime;
        private System.Windows.Forms.DateTimePicker dtpStartDate;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button btnEndDate;
        private System.Windows.Forms.Button butStartDate;
        private System.Windows.Forms.TextBox txtRemark;
        protected MESButton_Top bGroup_Down;
        private ButtonBox bGroup;
        protected MESButton_Top bGroup_Up;
        private System.Windows.Forms.Label label11;



    }
}
