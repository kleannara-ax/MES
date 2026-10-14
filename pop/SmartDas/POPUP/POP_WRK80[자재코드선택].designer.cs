namespace SmartDas.POPUP
{
    partial class POP_WRK80
    {

        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            Infragistics.Win.ValueListItem valueListItem1 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem2 = new Infragistics.Win.ValueListItem();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK80));
            this.lblLabel1 = new System.Windows.Forms.Label();
            this.lblLabel2 = new System.Windows.Forms.Label();
            this.lblLabel3 = new System.Windows.Forms.Label();
            this.lblLabel4 = new System.Windows.Forms.Label();
            this.lblLabel5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.panelWidthLength = new System.Windows.Forms.Panel();
            this.lblLength = new SmartDas.Components.MESLabel();
            this.lblWidth = new SmartDas.Components.MESLabel();
            this.ucMachineLine = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.lblWeight = new SmartDas.Components.MESLabel();
            this.btnFind = new SmartDas.Components.MESButton();
            this.lblMachineLine = new SmartDas.Components.MESLabel();
            this.lblPCode = new SmartDas.Components.MESLabel();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.btnLeftPage = new SmartDas.Components.MESButton_Top();
            this.btnRightPage = new SmartDas.Components.MESButton_Top();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.panelWidthLength.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ucMachineLine)).BeginInit();
            this.SuspendLayout();
            // 
            // lblLabel1
            // 
            this.lblLabel1.BackColor = System.Drawing.Color.Gray;
            this.lblLabel1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel1.ForeColor = System.Drawing.Color.White;
            this.lblLabel1.Location = new System.Drawing.Point(9, 81);
            this.lblLabel1.Name = "lblLabel1";
            this.lblLabel1.Size = new System.Drawing.Size(80, 40);
            this.lblLabel1.TabIndex = 140;
            this.lblLabel1.Text = "호기";
            this.lblLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel2
            // 
            this.lblLabel2.BackColor = System.Drawing.Color.Gray;
            this.lblLabel2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel2.ForeColor = System.Drawing.Color.White;
            this.lblLabel2.Location = new System.Drawing.Point(203, 81);
            this.lblLabel2.Name = "lblLabel2";
            this.lblLabel2.Size = new System.Drawing.Size(100, 40);
            this.lblLabel2.TabIndex = 143;
            this.lblLabel2.Text = "지종코드";
            this.lblLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel3
            // 
            this.lblLabel3.BackColor = System.Drawing.Color.Gray;
            this.lblLabel3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel3.ForeColor = System.Drawing.Color.White;
            this.lblLabel3.Location = new System.Drawing.Point(407, 81);
            this.lblLabel3.Name = "lblLabel3";
            this.lblLabel3.Size = new System.Drawing.Size(80, 40);
            this.lblLabel3.TabIndex = 146;
            this.lblLabel3.Text = "평량";
            this.lblLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel4
            // 
            this.lblLabel4.BackColor = System.Drawing.Color.Gray;
            this.lblLabel4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel4.ForeColor = System.Drawing.Color.White;
            this.lblLabel4.Location = new System.Drawing.Point(4, 5);
            this.lblLabel4.Name = "lblLabel4";
            this.lblLabel4.Size = new System.Drawing.Size(80, 40);
            this.lblLabel4.TabIndex = 148;
            this.lblLabel4.Text = "가로";
            this.lblLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel5
            // 
            this.lblLabel5.BackColor = System.Drawing.Color.Gray;
            this.lblLabel5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel5.ForeColor = System.Drawing.Color.White;
            this.lblLabel5.Location = new System.Drawing.Point(188, 5);
            this.lblLabel5.Name = "lblLabel5";
            this.lblLabel5.Size = new System.Drawing.Size(80, 40);
            this.lblLabel5.TabIndex = 150;
            this.lblLabel5.Text = "세로";
            this.lblLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(6, 634);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(153, 57);
            this.label6.TabIndex = 152;
            this.label6.Text = "자재번호";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panelWidthLength
            // 
            this.panelWidthLength.Controls.Add(this.lblLength);
            this.panelWidthLength.Controls.Add(this.lblWidth);
            this.panelWidthLength.Controls.Add(this.lblLabel4);
            this.panelWidthLength.Controls.Add(this.lblLabel5);
            this.panelWidthLength.Location = new System.Drawing.Point(589, 76);
            this.panelWidthLength.Name = "panelWidthLength";
            this.panelWidthLength.Size = new System.Drawing.Size(370, 49);
            this.panelWidthLength.TabIndex = 216;
            // 
            // lblLength
            // 
            this.lblLength.BackColor = System.Drawing.Color.White;
            this.lblLength.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLength.ColorContent = System.Drawing.Color.Transparent;
            this.lblLength.ColorLabel = System.Drawing.Color.White;
            this.lblLength.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLength.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLength.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLength.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLength.Location = new System.Drawing.Point(275, 5);
            this.lblLength.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblLength.MoveControl = null;
            this.lblLength.Name = "lblLength";
            this.lblLength.Size = new System.Drawing.Size(90, 40);
            this.lblLength.TabIndex = 151;
            this.lblLength.Tag = "세로 입력";
            this.lblLength.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblLength.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblLength.Click += new System.EventHandler(this.lblLength_Click);
            // 
            // lblWidth
            // 
            this.lblWidth.BackColor = System.Drawing.Color.White;
            this.lblWidth.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWidth.ColorContent = System.Drawing.Color.Transparent;
            this.lblWidth.ColorLabel = System.Drawing.Color.White;
            this.lblWidth.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWidth.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWidth.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWidth.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWidth.Location = new System.Drawing.Point(91, 5);
            this.lblWidth.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblWidth.MoveControl = null;
            this.lblWidth.Name = "lblWidth";
            this.lblWidth.Size = new System.Drawing.Size(90, 40);
            this.lblWidth.TabIndex = 149;
            this.lblWidth.Tag = "가로 입력";
            this.lblWidth.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWidth.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWidth.Click += new System.EventHandler(this.lblWidth_Click);
            // 
            // ucMachineLine
            // 
            appearance2.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucMachineLine.Appearance = appearance2;
            this.ucMachineLine.AutoSize = false;
            this.ucMachineLine.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucMachineLine.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucMachineLine.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            valueListItem1.DataValue = "ValueListItem0";
            valueListItem1.DisplayText = "2호기";
            valueListItem1.Tag = "2";
            valueListItem2.DataValue = "ValueListItem1";
            valueListItem2.DisplayText = "3호기";
            valueListItem2.Tag = "3";
            this.ucMachineLine.Items.AddRange(new Infragistics.Win.ValueListItem[] {
            valueListItem1,
            valueListItem2});
            this.ucMachineLine.Location = new System.Drawing.Point(97, 103);
            this.ucMachineLine.MinimumSize = new System.Drawing.Size(0, 45);
            this.ucMachineLine.Name = "ucMachineLine";
            this.ucMachineLine.Size = new System.Drawing.Size(100, 45);
            this.ucMachineLine.TabIndex = 272;
            this.ucMachineLine.Visible = false;
            // 
            // Grid1
            // 
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.Font = new System.Drawing.Font("맑은 고딕", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(6, 141);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1112, 484);
            this.Grid1.TabIndex = 154;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.GridClick += new SmartDas.Components.MESGrid.gridClick(this.Grid1_GridClick);
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.Black;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.Black;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.ForeColor = System.Drawing.Color.Yellow;
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(173, 634);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(411, 57);
            this.lblMATNR.TabIndex = 153;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWeight
            // 
            this.lblWeight.BackColor = System.Drawing.Color.White;
            this.lblWeight.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWeight.ColorContent = System.Drawing.Color.Transparent;
            this.lblWeight.ColorLabel = System.Drawing.Color.White;
            this.lblWeight.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWeight.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWeight.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWeight.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWeight.Location = new System.Drawing.Point(494, 81);
            this.lblWeight.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblWeight.MoveControl = null;
            this.lblWeight.Name = "lblWeight";
            this.lblWeight.Size = new System.Drawing.Size(90, 40);
            this.lblWeight.TabIndex = 147;
            this.lblWeight.Tag = "평량 입력";
            this.lblWeight.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWeight.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWeight.Click += new System.EventHandler(this.lblWeight_Click);
            // 
            // btnFind
            // 
            this.btnFind.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnFind.BackColor = System.Drawing.Color.Transparent;
            this.btnFind.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnFind.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnFind.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnFind.ButtonPressed = false;
            this.btnFind.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnFind.DownPic = null;
            this.btnFind.ExTag = null;
            this.btnFind.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(966, 72);
            this.btnFind.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(153, 57);
            this.btnFind.TabIndex = 145;
            this.btnFind.Text = "조회";
            this.btnFind.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnFind.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnFind.UpPic = null;
            this.btnFind.UseFlag = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // lblMachineLine
            // 
            this.lblMachineLine.BackColor = System.Drawing.Color.White;
            this.lblMachineLine.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMachineLine.ColorContent = System.Drawing.Color.Transparent;
            this.lblMachineLine.ColorLabel = System.Drawing.Color.White;
            this.lblMachineLine.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMachineLine.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMachineLine.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMachineLine.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMachineLine.Location = new System.Drawing.Point(96, 81);
            this.lblMachineLine.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblMachineLine.MoveControl = null;
            this.lblMachineLine.Name = "lblMachineLine";
            this.lblMachineLine.Size = new System.Drawing.Size(100, 40);
            this.lblMachineLine.TabIndex = 141;
            this.lblMachineLine.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMachineLine.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblMachineLine.Visible = false;
            // 
            // lblPCode
            // 
            this.lblPCode.BackColor = System.Drawing.Color.White;
            this.lblPCode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPCode.ColorContent = System.Drawing.Color.Transparent;
            this.lblPCode.ColorLabel = System.Drawing.Color.White;
            this.lblPCode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPCode.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPCode.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPCode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPCode.Location = new System.Drawing.Point(310, 81);
            this.lblPCode.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblPCode.MoveControl = null;
            this.lblPCode.Name = "lblPCode";
            this.lblPCode.Size = new System.Drawing.Size(90, 40);
            this.lblPCode.TabIndex = 144;
            this.lblPCode.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPCode.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPCode.Click += new System.EventHandler(this.lblPType_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnConfirm.BackColor = System.Drawing.Color.Transparent;
            this.btnConfirm.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnConfirm.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnConfirm.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnConfirm.ButtonPressed = false;
            this.btnConfirm.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnConfirm.DownPic = null;
            this.btnConfirm.ExTag = null;
            this.btnConfirm.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FontSize = 14F;
            this.btnConfirm.LinkButtonBox = null;
            this.btnConfirm.LinkDatePicker = null;
            this.btnConfirm.LinkGrid = null;
            this.btnConfirm.LinkMoveSize = 0;
            this.btnConfirm.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnConfirm.Location = new System.Drawing.Point(768, 634);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(160, 57);
            this.btnConfirm.TabIndex = 139;
            this.btnConfirm.Text = "선택";
            this.btnConfirm.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnConfirm.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnConfirm.UpPic = null;
            this.btnConfirm.UseFlag = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 14F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(959, 634);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(160, 57);
            this.btnCancel.TabIndex = 86;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnLeftPage.BackColor = System.Drawing.Color.Transparent;
            this.btnLeftPage.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnLeftPage.BackgroundImage = global::SmartDas.Properties.Resources.상단왼쪽01;
            this.btnLeftPage.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLeftPage.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.btnLeftPage.ButtonPressed = false;
            this.btnLeftPage.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnLeftPage.ExTag = null;
            this.btnLeftPage.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.btnLeftPage.FontSize = 24F;
            this.btnLeftPage.LinkButtonBox = null;
            this.btnLeftPage.LinkGrid = this.Grid1;
            this.btnLeftPage.LinkMoveSize = 9;
            this.btnLeftPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.btnLeftPage.Location = new System.Drawing.Point(6, 6);
            this.btnLeftPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnLeftPage.Name = "btnLeftPage";
            this.btnLeftPage.ParentBox = null;
            this.btnLeftPage.Size = new System.Drawing.Size(64, 59);
            this.btnLeftPage.TabIndex = 85;
            this.btnLeftPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnLeftPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnLeftPage.UseFlag = true;
            // 
            // btnRightPage
            // 
            this.btnRightPage.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnRightPage.BackColor = System.Drawing.Color.Transparent;
            this.btnRightPage.BackGradientStyle = Infragistics.Win.GradientStyle.Circular;
            this.btnRightPage.BackgroundImage = global::SmartDas.Properties.Resources.상단오른쪽01;
            this.btnRightPage.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnRightPage.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.btnRightPage.ButtonPressed = false;
            this.btnRightPage.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnRightPage.ExTag = null;
            this.btnRightPage.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.btnRightPage.FontSize = 24F;
            this.btnRightPage.LinkButtonBox = null;
            this.btnRightPage.LinkGrid = this.Grid1;
            this.btnRightPage.LinkMoveSize = 9;
            this.btnRightPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.btnRightPage.Location = new System.Drawing.Point(1055, 6);
            this.btnRightPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnRightPage.Name = "btnRightPage";
            this.btnRightPage.ParentBox = null;
            this.btnRightPage.Size = new System.Drawing.Size(64, 59);
            this.btnRightPage.TabIndex = 84;
            this.btnRightPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnRightPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnRightPage.UseFlag = true;
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(79, 6);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(971, 59);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "자재코드 선택";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK80
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(1130, 701);
            this.ControlBox = false;
            this.Controls.Add(this.ucMachineLine);
            this.Controls.Add(this.panelWidthLength);
            this.Controls.Add(this.Grid1);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.lblMATNR);
            this.Controls.Add(this.lblLabel3);
            this.Controls.Add(this.lblWeight);
            this.Controls.Add(this.btnFind);
            this.Controls.Add(this.lblLabel1);
            this.Controls.Add(this.lblMachineLine);
            this.Controls.Add(this.lblLabel2);
            this.Controls.Add(this.lblPCode);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnLeftPage);
            this.Controls.Add(this.btnRightPage);
            this.Controls.Add(this.labTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_WRK80";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK80_Load);
            this.panelWidthLength.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.ucMachineLine)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel labTitle;
        protected Components.MESButton_Top btnRightPage;
        protected Components.MESButton_Top btnLeftPage;
        private Components.MESButton btnCancel;
        private Components.MESButton btnConfirm;
        private System.Windows.Forms.Label lblLabel1;
        private Components.MESLabel lblMachineLine;
        private System.Windows.Forms.Label lblLabel2;
        private Components.MESLabel lblPCode;
        private System.Windows.Forms.Label lblLabel5;
        private Components.MESLabel lblLength;
        private System.Windows.Forms.Label lblLabel4;
        private Components.MESLabel lblWidth;
        private System.Windows.Forms.Label lblLabel3;
        private Components.MESLabel lblWeight;
        private Components.MESButton btnFind;
        private System.Windows.Forms.Label label6;
        private Components.MESLabel lblMATNR;
        private Components.MESGrid Grid1;
        private System.Windows.Forms.Panel panelWidthLength;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucMachineLine;
    }
}