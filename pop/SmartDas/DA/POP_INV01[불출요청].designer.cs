using SmartDas.Components;

namespace SmartDas
{
    partial class POP_INV01
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_INV01));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.btnSave = new SmartDas.Components.MESButton();
            this.label9 = new System.Windows.Forms.Label();
            this.lblEA_QTY = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWGT = new SmartDas.Components.MESLabel();
            this.label7 = new System.Windows.Forms.Label();
            this.lblLENGTH = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.lblROLL_QTY = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblBAG_QTY = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblBOX_QTY = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblPLT_QTY = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.lblREQ_QTY = new SmartDas.Components.MESLabel();
            this.Grid2 = new SmartDas.Components.MESGrid();
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
            this.btnRightPage.LinkGrid = this.Grid2;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid2;
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
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.btnSave);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.lblEA_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWGT);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.lblLENGTH);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.lblROLL_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblBAG_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblBOX_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblPLT_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblREQ_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.Grid2);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
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
            this.Grid1.Location = new System.Drawing.Point(815, 3);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(440, 550);
            this.Grid1.TabIndex = 208;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            // 
            // btnSave
            // 
            this.btnSave.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnSave.BackColor = System.Drawing.Color.Transparent;
            this.btnSave.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnSave.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnSave.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnSave.ButtonPressed = false;
            this.btnSave.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnSave.DownPic = null;
            this.btnSave.ExTag = null;
            this.btnSave.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnSave.FontSize = 14F;
            this.btnSave.LinkButtonBox = null;
            this.btnSave.LinkDatePicker = null;
            this.btnSave.LinkGrid = null;
            this.btnSave.LinkMoveSize = 0;
            this.btnSave.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnSave.Location = new System.Drawing.Point(397, 560);
            this.btnSave.Margin = new System.Windows.Forms.Padding(0);
            this.btnSave.Name = "btnSave";
            this.btnSave.ParentBox = null;
            this.btnSave.Size = new System.Drawing.Size(380, 105);
            this.btnSave.TabIndex = 207;
            this.btnSave.Text = "요청수량 저장";
            this.btnSave.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnSave.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnSave.UpPic = null;
            this.btnSave.UseFlag = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(784, 730);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(120, 50);
            this.label9.TabIndex = 79;
            this.label9.Text = "EA";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblEA_QTY.Location = new System.Drawing.Point(910, 730);
            this.lblEA_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEA_QTY.MoveControl = null;
            this.lblEA_QTY.Name = "lblEA_QTY";
            this.lblEA_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblEA_QTY.TabIndex = 80;
            this.lblEA_QTY.Tag = "EA";
            this.lblEA_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblEA_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEA_QTY.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(784, 673);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(120, 50);
            this.label6.TabIndex = 77;
            this.label6.Text = "KG";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWGT
            // 
            this.lblWGT.BackColor = System.Drawing.Color.LightGray;
            this.lblWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWGT.Location = new System.Drawing.Point(910, 673);
            this.lblWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWGT.MoveControl = null;
            this.lblWGT.Name = "lblWGT";
            this.lblWGT.Size = new System.Drawing.Size(250, 50);
            this.lblWGT.TabIndex = 78;
            this.lblWGT.Tag = "KG";
            this.lblWGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWGT.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(400, 730);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(120, 50);
            this.label7.TabIndex = 75;
            this.label7.Text = "M";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLENGTH
            // 
            this.lblLENGTH.BackColor = System.Drawing.Color.LightGray;
            this.lblLENGTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLENGTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblLENGTH.ColorLabel = System.Drawing.Color.LightGray;
            this.lblLENGTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLENGTH.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLENGTH.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLENGTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLENGTH.Location = new System.Drawing.Point(526, 730);
            this.lblLENGTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLENGTH.MoveControl = null;
            this.lblLENGTH.Name = "lblLENGTH";
            this.lblLENGTH.Size = new System.Drawing.Size(250, 50);
            this.lblLENGTH.TabIndex = 76;
            this.lblLENGTH.Tag = "M";
            this.lblLENGTH.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblLENGTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblLENGTH.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Gray;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(400, 673);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(120, 50);
            this.label8.TabIndex = 73;
            this.label8.Text = "RL";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblROLL_QTY
            // 
            this.lblROLL_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblROLL_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblROLL_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblROLL_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblROLL_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblROLL_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblROLL_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblROLL_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblROLL_QTY.Location = new System.Drawing.Point(526, 673);
            this.lblROLL_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblROLL_QTY.MoveControl = null;
            this.lblROLL_QTY.Name = "lblROLL_QTY";
            this.lblROLL_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblROLL_QTY.TabIndex = 74;
            this.lblROLL_QTY.Tag = "RL";
            this.lblROLL_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblROLL_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblROLL_QTY.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(16, 731);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(120, 50);
            this.label5.TabIndex = 71;
            this.label5.Text = "BAG";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblBAG_QTY.Location = new System.Drawing.Point(142, 731);
            this.lblBAG_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBAG_QTY.MoveControl = null;
            this.lblBAG_QTY.Name = "lblBAG_QTY";
            this.lblBAG_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBAG_QTY.TabIndex = 72;
            this.lblBAG_QTY.Tag = "BAG";
            this.lblBAG_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBAG_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblBAG_QTY.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(16, 673);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(120, 50);
            this.label4.TabIndex = 69;
            this.label4.Text = "BOX";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblBOX_QTY.Location = new System.Drawing.Point(142, 673);
            this.lblBOX_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBOX_QTY.MoveControl = null;
            this.lblBOX_QTY.Name = "lblBOX_QTY";
            this.lblBOX_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBOX_QTY.TabIndex = 70;
            this.lblBOX_QTY.Tag = "BOX";
            this.lblBOX_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBOX_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblBOX_QTY.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(16, 616);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(120, 50);
            this.label3.TabIndex = 67;
            this.label3.Text = "PLT";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.lblPLT_QTY.Location = new System.Drawing.Point(142, 616);
            this.lblPLT_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPLT_QTY.MoveControl = null;
            this.lblPLT_QTY.Name = "lblPLT_QTY";
            this.lblPLT_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblPLT_QTY.TabIndex = 68;
            this.lblPLT_QTY.Tag = "PLT";
            this.lblPLT_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPLT_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPLT_QTY.Click += new System.EventHandler(this.lblUNIT_QTY_Click);
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(16, 560);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(120, 50);
            this.label2.TabIndex = 65;
            this.label2.Text = "요청수량";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblREQ_QTY
            // 
            this.lblREQ_QTY.BackColor = System.Drawing.Color.White;
            this.lblREQ_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblREQ_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblREQ_QTY.ColorLabel = System.Drawing.Color.White;
            this.lblREQ_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblREQ_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblREQ_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblREQ_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblREQ_QTY.Location = new System.Drawing.Point(142, 560);
            this.lblREQ_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblREQ_QTY.MoveControl = null;
            this.lblREQ_QTY.Name = "lblREQ_QTY";
            this.lblREQ_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblREQ_QTY.TabIndex = 66;
            this.lblREQ_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblREQ_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblREQ_QTY.Click += new System.EventHandler(this.lblREQ_QTY_Click);
            // 
            // Grid2
            // 
            this.Grid2.AutoScroll = true;
            this.Grid2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid2.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid2.CountRows = 0;
            this.Grid2.DataSource = null;
            this.Grid2.FixedCols = 0;
            this.Grid2.FontSize = 20.25F;
            this.Grid2.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid2.HeaderFontSize = 13F;
            this.Grid2.HeadString = null;
            this.Grid2.Location = new System.Drawing.Point(9, 3);
            this.Grid2.Name = "Grid2";
            this.Grid2.Row = null;
            this.Grid2.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid2.SelectCommand = null;
            this.Grid2.SelectProcedureName = null;
            this.Grid2.Size = new System.Drawing.Size(800, 550);
            this.Grid2.TabIndex = 64;
            this.Grid2.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid2.GridClick += new SmartDas.Components.MESGrid.gridClick(this.Grid2_GridClick);
            this.Grid2.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid2_ClickCellButton);
            // 
            // POP_INV01
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_INV01";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_INV01_Load);
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
        private MESGrid Grid2;
        private System.Windows.Forms.Label label2;
        private MESLabel lblREQ_QTY;
        private System.Windows.Forms.Label label6;
        private MESLabel lblWGT;
        private System.Windows.Forms.Label label7;
        private MESLabel lblLENGTH;
        private System.Windows.Forms.Label label8;
        private MESLabel lblROLL_QTY;
        private System.Windows.Forms.Label label5;
        private MESLabel lblBAG_QTY;
        private System.Windows.Forms.Label label4;
        private MESLabel lblBOX_QTY;
        private System.Windows.Forms.Label label3;
        private MESLabel lblPLT_QTY;
        private System.Windows.Forms.Label label9;
        private MESLabel lblEA_QTY;
        private MESGrid Grid1;
        private MESButton btnSave;

    }
}
