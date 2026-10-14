using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK51
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK51));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.btnMove = new SmartDas.Components.MESButton();
            this.lblMACH_STA = new System.Windows.Forms.Label();
            this.txtRMK = new System.Windows.Forms.TextBox();
            this.label17 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label16 = new System.Windows.Forms.Label();
            this.lblWaste = new SmartDas.Components.MESLabel();
            this.lblWorkSpeed = new SmartDas.Components.MESLabel();
            this.label15 = new System.Windows.Forms.Label();
            this.lblTM = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.lblWGT = new SmartDas.Components.MESLabel();
            this.btnPRD_END_DATE = new System.Windows.Forms.Button();
            this.btnPRD_STR_DATE = new System.Windows.Forms.Button();
            this.lblPRD_END_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.label11 = new System.Windows.Forms.Label();
            this.lblPRD_STR_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.label9 = new System.Windows.Forms.Label();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.label2 = new System.Windows.Forms.Label();
            this.lblTubeWGT = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblWIDTH = new SmartDas.Components.MESLabel();
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
            // lblMessage
            // 
            this.lblMessage.Position = 443;
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
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblWIDTH);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblTubeWGT);
            this.splitContainer1.Panel1.Controls.Add(this.btnMove);
            this.splitContainer1.Panel1.Controls.Add(this.lblMACH_STA);
            this.splitContainer1.Panel1.Controls.Add(this.txtRMK);
            this.splitContainer1.Panel1.Controls.Add(this.label17);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.label16);
            this.splitContainer1.Panel1.Controls.Add(this.lblWaste);
            this.splitContainer1.Panel1.Controls.Add(this.lblWorkSpeed);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.lblTM);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblWGT);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_END_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_STR_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // btnMove
            // 
            this.btnMove.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnMove.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(49)))), ((int)(((byte)(98)))), ((int)(((byte)(165)))));
            this.btnMove.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnMove.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnMove.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnMove.ButtonPressed = false;
            this.btnMove.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnMove.DownPic = null;
            this.btnMove.ExTag = null;
            this.btnMove.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnMove.FontSize = 14F;
            this.btnMove.ForeColor = System.Drawing.Color.Black;
            this.btnMove.LinkButtonBox = null;
            this.btnMove.LinkDatePicker = null;
            this.btnMove.LinkGrid = null;
            this.btnMove.LinkMoveSize = 0;
            this.btnMove.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnMove.Location = new System.Drawing.Point(1077, 663);
            this.btnMove.Margin = new System.Windows.Forms.Padding(0);
            this.btnMove.Name = "btnMove";
            this.btnMove.ParentBox = null;
            this.btnMove.Size = new System.Drawing.Size(182, 109);
            this.btnMove.TabIndex = 231;
            this.btnMove.Text = "합지기화면이동";
            this.btnMove.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnMove.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnMove.UpPic = null;
            this.btnMove.UseFlag = true;
            this.btnMove.Click += new System.EventHandler(this.btnMove_Click);
            // 
            // lblMACH_STA
            // 
            this.lblMACH_STA.BackColor = System.Drawing.Color.Black;
            this.lblMACH_STA.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMACH_STA.ForeColor = System.Drawing.Color.Lime;
            this.lblMACH_STA.Location = new System.Drawing.Point(1077, 492);
            this.lblMACH_STA.Name = "lblMACH_STA";
            this.lblMACH_STA.Size = new System.Drawing.Size(182, 165);
            this.lblMACH_STA.TabIndex = 230;
            this.lblMACH_STA.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtRMK
            // 
            this.txtRMK.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtRMK.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtRMK.Location = new System.Drawing.Point(822, 663);
            this.txtRMK.MinimumSize = new System.Drawing.Size(247, 110);
            this.txtRMK.Name = "txtRMK";
            this.txtRMK.Size = new System.Drawing.Size(247, 110);
            this.txtRMK.TabIndex = 229;
            // 
            // label17
            // 
            this.label17.BackColor = System.Drawing.Color.Gray;
            this.label17.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label17.ForeColor = System.Drawing.Color.White;
            this.label17.Location = new System.Drawing.Point(664, 662);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(149, 110);
            this.label17.TabIndex = 228;
            this.label17.Text = "비고";
            this.label17.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(663, 607);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 226;
            this.label1.Text = "폐품 량(Kg)";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label16
            // 
            this.label16.BackColor = System.Drawing.Color.Gray;
            this.label16.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label16.ForeColor = System.Drawing.Color.White;
            this.label16.Location = new System.Drawing.Point(663, 550);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(150, 50);
            this.label16.TabIndex = 226;
            this.label16.Text = "총 폐품량";
            this.label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWaste
            // 
            this.lblWaste.BackColor = System.Drawing.Color.LightGray;
            this.lblWaste.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWaste.ColorContent = System.Drawing.Color.Transparent;
            this.lblWaste.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWaste.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWaste.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWaste.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWaste.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWaste.Location = new System.Drawing.Point(822, 607);
            this.lblWaste.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWaste.MoveControl = null;
            this.lblWaste.Name = "lblWaste";
            this.lblWaste.Size = new System.Drawing.Size(247, 50);
            this.lblWaste.TabIndex = 227;
            this.lblWaste.Text = "0";
            this.lblWaste.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWaste.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWaste.Click += new System.EventHandler(this.lblWaste_Click);
            // 
            // lblWorkSpeed
            // 
            this.lblWorkSpeed.BackColor = System.Drawing.Color.LightGray;
            this.lblWorkSpeed.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWorkSpeed.ColorContent = System.Drawing.Color.Transparent;
            this.lblWorkSpeed.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWorkSpeed.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWorkSpeed.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWorkSpeed.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWorkSpeed.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWorkSpeed.Location = new System.Drawing.Point(822, 551);
            this.lblWorkSpeed.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWorkSpeed.MoveControl = null;
            this.lblWorkSpeed.Name = "lblWorkSpeed";
            this.lblWorkSpeed.Size = new System.Drawing.Size(247, 50);
            this.lblWorkSpeed.TabIndex = 227;
            this.lblWorkSpeed.Text = "0";
            this.lblWorkSpeed.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWorkSpeed.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Gray;
            this.label15.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(663, 494);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(150, 50);
            this.label15.TabIndex = 224;
            this.label15.Text = "가동시간(분)";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTM
            // 
            this.lblTM.BackColor = System.Drawing.Color.LightGray;
            this.lblTM.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTM.ColorContent = System.Drawing.Color.Transparent;
            this.lblTM.ColorLabel = System.Drawing.Color.LightGray;
            this.lblTM.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTM.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTM.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTM.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTM.Location = new System.Drawing.Point(822, 495);
            this.lblTM.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTM.MoveControl = null;
            this.lblTM.Name = "lblTM";
            this.lblTM.Size = new System.Drawing.Size(247, 50);
            this.lblTM.TabIndex = 225;
            this.lblTM.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTM.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Gray;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(9, 603);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(150, 50);
            this.label14.TabIndex = 222;
            this.label14.Text = "총 중량(Kg)";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWGT
            // 
            this.lblWGT.BackColor = System.Drawing.Color.White;
            this.lblWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWGT.ColorLabel = System.Drawing.Color.White;
            this.lblWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWGT.Location = new System.Drawing.Point(163, 605);
            this.lblWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWGT.MoveControl = null;
            this.lblWGT.Name = "lblWGT";
            this.lblWGT.Size = new System.Drawing.Size(485, 50);
            this.lblWGT.TabIndex = 223;
            this.lblWGT.Text = "0";
            this.lblWGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWGT.Click += new System.EventHandler(this.lblWGT_Click);
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
            this.btnPRD_END_DATE.Location = new System.Drawing.Point(435, 551);
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
            this.btnPRD_STR_DATE.Location = new System.Drawing.Point(435, 495);
            this.btnPRD_STR_DATE.Name = "btnPRD_STR_DATE";
            this.btnPRD_STR_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_STR_DATE.TabIndex = 220;
            this.btnPRD_STR_DATE.Tag = "startDate";
            this.btnPRD_STR_DATE.UseVisualStyleBackColor = false;
            this.btnPRD_STR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
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
            this.lblPRD_END_TIME.Location = new System.Drawing.Point(500, 548);
            this.lblPRD_END_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_END_TIME.MoveControl = null;
            this.lblPRD_END_TIME.Name = "lblPRD_END_TIME";
            this.lblPRD_END_TIME.Size = new System.Drawing.Size(148, 50);
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
            this.dtpPRD_END_DATE.Location = new System.Drawing.Point(163, 548);
            this.dtpPRD_END_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_END_DATE.Name = "dtpPRD_END_DATE";
            this.dtpPRD_END_DATE.ShowUpDown = true;
            this.dtpPRD_END_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_END_DATE.TabIndex = 215;
            this.dtpPRD_END_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Gray;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(8, 548);
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
            this.lblPRD_STR_TIME.Location = new System.Drawing.Point(500, 492);
            this.lblPRD_STR_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_STR_TIME.MoveControl = null;
            this.lblPRD_STR_TIME.Name = "lblPRD_STR_TIME";
            this.lblPRD_STR_TIME.Size = new System.Drawing.Size(148, 50);
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
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(163, 492);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_STR_DATE.TabIndex = 212;
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(8, 492);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(150, 50);
            this.label9.TabIndex = 211;
            this.label9.Text = "시작일시";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.Grid1.Location = new System.Drawing.Point(9, 12);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.Automatic;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 471);
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
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(9, 664);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 232;
            this.label2.Text = "지관무게";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTubeWGT
            // 
            this.lblTubeWGT.BackColor = System.Drawing.Color.White;
            this.lblTubeWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTubeWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblTubeWGT.ColorLabel = System.Drawing.Color.White;
            this.lblTubeWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTubeWGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTubeWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTubeWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTubeWGT.Location = new System.Drawing.Point(163, 664);
            this.lblTubeWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTubeWGT.MoveControl = null;
            this.lblTubeWGT.Name = "lblTubeWGT";
            this.lblTubeWGT.Size = new System.Drawing.Size(485, 50);
            this.lblTubeWGT.TabIndex = 233;
            this.lblTubeWGT.Text = "0";
            this.lblTubeWGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTubeWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblTubeWGT.Click += new System.EventHandler(this.lblTubeWGT_Click);
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(9, 722);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 234;
            this.label3.Text = "총지폭";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWIDTH
            // 
            this.lblWIDTH.BackColor = System.Drawing.Color.White;
            this.lblWIDTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWIDTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblWIDTH.ColorLabel = System.Drawing.Color.White;
            this.lblWIDTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWIDTH.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWIDTH.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWIDTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWIDTH.Location = new System.Drawing.Point(163, 722);
            this.lblWIDTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWIDTH.MoveControl = null;
            this.lblWIDTH.Name = "lblWIDTH";
            this.lblWIDTH.Size = new System.Drawing.Size(485, 50);
            this.lblWIDTH.TabIndex = 235;
            this.lblWIDTH.Text = "2950";
            this.lblWIDTH.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWIDTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWIDTH.Click += new System.EventHandler(this.lblWIDTH_Click);
            // 
            // POP_WRK51
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK51";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK51_Load);
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
        private MESGrid Grid1;
        private MESLabel lblPRD_END_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_END_DATE;
        private System.Windows.Forms.Label label11;
        private MESLabel lblPRD_STR_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Button btnPRD_END_DATE;
        private System.Windows.Forms.Button btnPRD_STR_DATE;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Label label14;
        private MESLabel lblWGT;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label16;
        private MESLabel lblWaste;
        private MESLabel lblWorkSpeed;
        private System.Windows.Forms.Label label15;
        private MESLabel lblTM;
        private System.Windows.Forms.TextBox txtRMK;
        private System.Windows.Forms.Label label17;
        private System.Windows.Forms.Label lblMACH_STA;
        private MESButton btnMove;
        private System.Windows.Forms.Label label3;
        private MESLabel lblWIDTH;
        private System.Windows.Forms.Label label2;
        private MESLabel lblTubeWGT;
    }
}
