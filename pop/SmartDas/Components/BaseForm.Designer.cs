namespace SmartDas.Components
{
    partial class BaseForm
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
            this.components = new System.ComponentModel.Container();
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(BaseForm));
            this.bgProcess = new System.ComponentModel.BackgroundWorker();
            this.TimeTimer = new System.Windows.Forms.Timer(this.components);
            this.EventTimer = new System.Windows.Forms.Timer(this.components);
            this.NetworkTimer = new System.Windows.Forms.Timer(this.components);
            this.BtLayoutPanel = new System.Windows.Forms.TableLayoutPanel();
            this.BPanelTop = new System.Windows.Forms.Panel();
            this.BPanelMainTitle = new System.Windows.Forms.Panel();
            this.lblMachineName = new System.Windows.Forms.Label();
            this.lblImage = new System.Windows.Forms.Panel();
            this.lblDate = new Infragistics.Win.Misc.UltraLabel();
            this.lblTime = new Infragistics.Win.Misc.UltraLabel();
            this.BPanelBottom = new System.Windows.Forms.Panel();
            this.BPanelBottomRight1 = new System.Windows.Forms.Panel();
            this.BPanelBottomLeft = new System.Windows.Forms.Panel();
            this.BPanelBottomRight2 = new System.Windows.Forms.Panel();
            this.BPanelBottomMiddle = new System.Windows.Forms.Panel();
            this.BPanelMain = new Infragistics.Win.Misc.UltraPanel();
            this.GroupBody = new Infragistics.Win.Misc.UltraGroupBox();
            this.btnRightPage = new SmartDas.Components.MESButton_Top();
            this.btnLeftPage = new SmartDas.Components.MESButton_Top();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.lblWorker = new SmartDas.Components.MESLabel();
            this.lblVer_Ip = new SmartDas.Components.MESLabel();
            this.lblNetwork = new SmartDas.Components.MESLabel();
            this.lblMessage = new SmartDas.Components.MESMarqueeLabel();
            this.BtLayoutPanel.SuspendLayout();
            this.BPanelTop.SuspendLayout();
            this.BPanelMainTitle.SuspendLayout();
            this.BPanelBottom.SuspendLayout();
            this.BPanelBottomRight1.SuspendLayout();
            this.BPanelBottomLeft.SuspendLayout();
            this.BPanelBottomRight2.SuspendLayout();
            this.BPanelBottomMiddle.SuspendLayout();
            this.BPanelMain.ClientArea.SuspendLayout();
            this.BPanelMain.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.SuspendLayout();
            // 
            // bgProcess
            // 
            this.bgProcess.WorkerSupportsCancellation = true;
            this.bgProcess.DoWork += new System.ComponentModel.DoWorkEventHandler(this.bgProcess_DoWork);
            // 
            // TimeTimer
            // 
            this.TimeTimer.Interval = 1000;
            this.TimeTimer.Tick += new System.EventHandler(this.TimeTimer_Tick);
            // 
            // EventTimer
            // 
            this.EventTimer.Interval = 800;
            this.EventTimer.Tick += new System.EventHandler(this.EventTimer_Tick);
            // 
            // BtLayoutPanel
            // 
            this.BtLayoutPanel.BackColor = System.Drawing.Color.Transparent;
            this.BtLayoutPanel.ColumnCount = 1;
            this.BtLayoutPanel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 1280F));
            this.BtLayoutPanel.Controls.Add(this.BPanelTop, 0, 0);
            this.BtLayoutPanel.Controls.Add(this.BPanelBottom, 0, 2);
            this.BtLayoutPanel.Controls.Add(this.BPanelMain, 0, 1);
            this.BtLayoutPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.BtLayoutPanel.Location = new System.Drawing.Point(0, 0);
            this.BtLayoutPanel.Name = "BtLayoutPanel";
            this.BtLayoutPanel.RowCount = 3;
            this.BtLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 70F));
            this.BtLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.BtLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 75F));
            this.BtLayoutPanel.Size = new System.Drawing.Size(1280, 1024);
            this.BtLayoutPanel.TabIndex = 0;
            // 
            // BPanelTop
            // 
            this.BPanelTop.BackColor = System.Drawing.Color.Transparent;
            this.BPanelTop.Controls.Add(this.BPanelMainTitle);
            this.BPanelTop.Dock = System.Windows.Forms.DockStyle.Fill;
            this.BPanelTop.Location = new System.Drawing.Point(0, 0);
            this.BPanelTop.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelTop.Name = "BPanelTop";
            this.BPanelTop.Size = new System.Drawing.Size(1280, 70);
            this.BPanelTop.TabIndex = 14;
            // 
            // BPanelMainTitle
            // 
            this.BPanelMainTitle.BackColor = System.Drawing.Color.Transparent;
            this.BPanelMainTitle.BackgroundImage = global::SmartDas.Properties.Resources.Top_Image;
            this.BPanelMainTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.BPanelMainTitle.Controls.Add(this.lblMachineName);
            this.BPanelMainTitle.Controls.Add(this.btnRightPage);
            this.BPanelMainTitle.Controls.Add(this.btnLeftPage);
            this.BPanelMainTitle.Controls.Add(this.lblImage);
            this.BPanelMainTitle.Controls.Add(this.lblDate);
            this.BPanelMainTitle.Controls.Add(this.lblTime);
            this.BPanelMainTitle.Controls.Add(this.lblTitle);
            this.BPanelMainTitle.Dock = System.Windows.Forms.DockStyle.Fill;
            this.BPanelMainTitle.Location = new System.Drawing.Point(0, 0);
            this.BPanelMainTitle.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelMainTitle.Name = "BPanelMainTitle";
            this.BPanelMainTitle.Size = new System.Drawing.Size(1280, 70);
            this.BPanelMainTitle.TabIndex = 1;
            // 
            // lblMachineName
            // 
            this.lblMachineName.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMachineName.Location = new System.Drawing.Point(988, 41);
            this.lblMachineName.Name = "lblMachineName";
            this.lblMachineName.Size = new System.Drawing.Size(212, 23);
            this.lblMachineName.TabIndex = 8;
            this.lblMachineName.Text = "3호기 초지기#3 – A조";
            this.lblMachineName.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lblImage
            // 
            this.lblImage.BackColor = System.Drawing.Color.Transparent;
            this.lblImage.BackgroundImage = global::SmartDas.Properties.Resources.KNRALogo;
            this.lblImage.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.lblImage.Location = new System.Drawing.Point(85, 3);
            this.lblImage.Name = "lblImage";
            this.lblImage.Size = new System.Drawing.Size(171, 64);
            this.lblImage.TabIndex = 5;
            this.lblImage.DoubleClick += new System.EventHandler(this.lblImage_DoubleClick);
            // 
            // lblDate
            // 
            appearance1.BackColor = System.Drawing.Color.Transparent;
            appearance1.ForeColor = System.Drawing.Color.Black;
            this.lblDate.Appearance = appearance1;
            this.lblDate.AutoSize = true;
            this.lblDate.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold);
            this.lblDate.Location = new System.Drawing.Point(1034, 14);
            this.lblDate.Name = "lblDate";
            this.lblDate.Size = new System.Drawing.Size(96, 24);
            this.lblDate.TabIndex = 3;
            this.lblDate.Text = "2012-00-00";
            // 
            // lblTime
            // 
            appearance2.BackColor = System.Drawing.Color.Transparent;
            appearance2.ForeColor = System.Drawing.Color.Black;
            this.lblTime.Appearance = appearance2;
            this.lblTime.AutoSize = true;
            this.lblTime.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold);
            this.lblTime.Location = new System.Drawing.Point(1129, 14);
            this.lblTime.Name = "lblTime";
            this.lblTime.Size = new System.Drawing.Size(72, 24);
            this.lblTime.TabIndex = 4;
            this.lblTime.Text = "00:00:00";
            // 
            // BPanelBottom
            // 
            this.BPanelBottom.BackColor = System.Drawing.Color.LightSteelBlue;
            this.BPanelBottom.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.BPanelBottom.Controls.Add(this.BPanelBottomRight1);
            this.BPanelBottom.Controls.Add(this.BPanelBottomLeft);
            this.BPanelBottom.Controls.Add(this.BPanelBottomRight2);
            this.BPanelBottom.Controls.Add(this.BPanelBottomMiddle);
            this.BPanelBottom.Dock = System.Windows.Forms.DockStyle.Fill;
            this.BPanelBottom.Location = new System.Drawing.Point(0, 949);
            this.BPanelBottom.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelBottom.Name = "BPanelBottom";
            this.BPanelBottom.Size = new System.Drawing.Size(1280, 75);
            this.BPanelBottom.TabIndex = 4;
            // 
            // BPanelBottomRight1
            // 
            this.BPanelBottomRight1.Controls.Add(this.lblWorker);
            this.BPanelBottomRight1.Location = new System.Drawing.Point(978, 6);
            this.BPanelBottomRight1.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelBottomRight1.Name = "BPanelBottomRight1";
            this.BPanelBottomRight1.Size = new System.Drawing.Size(148, 62);
            this.BPanelBottomRight1.TabIndex = 7;
            // 
            // BPanelBottomLeft
            // 
            this.BPanelBottomLeft.Controls.Add(this.lblVer_Ip);
            this.BPanelBottomLeft.Location = new System.Drawing.Point(7, 6);
            this.BPanelBottomLeft.Name = "BPanelBottomLeft";
            this.BPanelBottomLeft.Size = new System.Drawing.Size(186, 62);
            this.BPanelBottomLeft.TabIndex = 5;
            // 
            // BPanelBottomRight2
            // 
            this.BPanelBottomRight2.Controls.Add(this.lblNetwork);
            this.BPanelBottomRight2.Location = new System.Drawing.Point(1132, 6);
            this.BPanelBottomRight2.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelBottomRight2.Name = "BPanelBottomRight2";
            this.BPanelBottomRight2.Size = new System.Drawing.Size(141, 62);
            this.BPanelBottomRight2.TabIndex = 6;
            // 
            // BPanelBottomMiddle
            // 
            this.BPanelBottomMiddle.Controls.Add(this.lblMessage);
            this.BPanelBottomMiddle.Location = new System.Drawing.Point(199, 6);
            this.BPanelBottomMiddle.Name = "BPanelBottomMiddle";
            this.BPanelBottomMiddle.Size = new System.Drawing.Size(773, 62);
            this.BPanelBottomMiddle.TabIndex = 4;
            // 
            // BPanelMain
            // 
            this.BPanelMain.BorderStyle = Infragistics.Win.UIElementBorderStyle.TwoColor;
            // 
            // BPanelMain.ClientArea
            // 
            this.BPanelMain.ClientArea.Controls.Add(this.GroupBody);
            this.BPanelMain.Location = new System.Drawing.Point(0, 70);
            this.BPanelMain.Margin = new System.Windows.Forms.Padding(0);
            this.BPanelMain.Name = "BPanelMain";
            this.BPanelMain.Size = new System.Drawing.Size(1280, 879);
            this.BPanelMain.TabIndex = 13;
            // 
            // GroupBody
            // 
            this.GroupBody.BorderStyle = Infragistics.Win.Misc.GroupBoxBorderStyle.None;
            this.GroupBody.Dock = System.Windows.Forms.DockStyle.Fill;
            this.GroupBody.Location = new System.Drawing.Point(0, 0);
            this.GroupBody.Margin = new System.Windows.Forms.Padding(0);
            this.GroupBody.Name = "GroupBody";
            this.GroupBody.Size = new System.Drawing.Size(1276, 875);
            this.GroupBody.TabIndex = 0;
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
            this.btnRightPage.LinkGrid = null;
            this.btnRightPage.LinkMoveSize = 0;
            this.btnRightPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.btnRightPage.Location = new System.Drawing.Point(1205, 10);
            this.btnRightPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnRightPage.Name = "btnRightPage";
            this.btnRightPage.ParentBox = null;
            this.btnRightPage.Size = new System.Drawing.Size(64, 53);
            this.btnRightPage.TabIndex = 7;
            this.btnRightPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnRightPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnRightPage.UseFlag = true;
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
            this.btnLeftPage.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.btnLeftPage.FontSize = 24F;
            this.btnLeftPage.LinkButtonBox = null;
            this.btnLeftPage.LinkGrid = null;
            this.btnLeftPage.LinkMoveSize = 0;
            this.btnLeftPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.btnLeftPage.Location = new System.Drawing.Point(9, 10);
            this.btnLeftPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnLeftPage.Name = "btnLeftPage";
            this.btnLeftPage.ParentBox = null;
            this.btnLeftPage.Size = new System.Drawing.Size(64, 53);
            this.btnLeftPage.TabIndex = 6;
            this.btnLeftPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnLeftPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnLeftPage.UseFlag = true;
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.Transparent;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.Transparent;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.LightGray;
            this.lblTitle.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(0, 0);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(0);
            this.lblTitle.MoveControl = null;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(1280, 70);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "화면 제목";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWorker
            // 
            this.lblWorker.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(49)))), ((int)(((byte)(98)))), ((int)(((byte)(165)))));
            this.lblWorker.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWorker.ColorContent = System.Drawing.Color.Transparent;
            this.lblWorker.ColorLabel = System.Drawing.Color.FromArgb(((int)(((byte)(49)))), ((int)(((byte)(98)))), ((int)(((byte)(165)))));
            this.lblWorker.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWorker.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lblWorker.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWorker.ForeColor = System.Drawing.Color.White;
            this.lblWorker.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWorker.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWorker.Location = new System.Drawing.Point(0, 0);
            this.lblWorker.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWorker.MoveControl = null;
            this.lblWorker.Name = "lblWorker";
            this.lblWorker.Size = new System.Drawing.Size(148, 62);
            this.lblWorker.TabIndex = 3;
            this.lblWorker.Text = "작업자";
            this.lblWorker.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWorker.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblVer_Ip
            // 
            this.lblVer_Ip.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(49)))), ((int)(((byte)(98)))), ((int)(((byte)(165)))));
            this.lblVer_Ip.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblVer_Ip.ColorContent = System.Drawing.Color.Transparent;
            this.lblVer_Ip.ColorLabel = System.Drawing.Color.FromArgb(((int)(((byte)(49)))), ((int)(((byte)(98)))), ((int)(((byte)(165)))));
            this.lblVer_Ip.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblVer_Ip.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lblVer_Ip.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblVer_Ip.ForeColor = System.Drawing.Color.White;
            this.lblVer_Ip.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblVer_Ip.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblVer_Ip.Location = new System.Drawing.Point(0, 0);
            this.lblVer_Ip.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblVer_Ip.MoveControl = null;
            this.lblVer_Ip.Name = "lblVer_Ip";
            this.lblVer_Ip.Size = new System.Drawing.Size(186, 62);
            this.lblVer_Ip.TabIndex = 1;
            this.lblVer_Ip.Text = "Ver:버전";
            this.lblVer_Ip.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblVer_Ip.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblNetwork
            // 
            this.lblNetwork.BackColor = System.Drawing.Color.Transparent;
            this.lblNetwork.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblNetwork.BackgroundImage = global::SmartDas.Properties.Resources.네트워크상태_01;
            this.lblNetwork.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblNetwork.ColorContent = System.Drawing.Color.Transparent;
            this.lblNetwork.ColorLabel = System.Drawing.Color.Transparent;
            this.lblNetwork.ColorReadOnly = System.Drawing.Color.LightGray;
            this.lblNetwork.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lblNetwork.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblNetwork.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblNetwork.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblNetwork.Location = new System.Drawing.Point(0, 0);
            this.lblNetwork.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.lblNetwork.MoveControl = null;
            this.lblNetwork.Name = "lblNetwork";
            this.lblNetwork.Size = new System.Drawing.Size(141, 62);
            this.lblNetwork.TabIndex = 2;
            this.lblNetwork.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblNetwork.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblMessage
            // 
            this.lblMessage.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.lblMessage.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMessage.ColorContent = System.Drawing.Color.Black;
            this.lblMessage.ColorLabel = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.lblMessage.ColorReadOnly = System.Drawing.Color.LightGray;
            this.lblMessage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lblMessage.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMessage.ForeColor = System.Drawing.Color.White;
            this.lblMessage.LabelType = SmartDas.Components.MESMarqueeLabel.LabelTypeEnum.Label;
            this.lblMessage.Location = new System.Drawing.Point(0, 0);
            this.lblMessage.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMessage.MarqueeType = SmartDas.Components.MESMarqueeLabel.MarqueeTypeEnum.RightToLeft;
            this.lblMessage.MoveControl = null;
            this.lblMessage.Name = "lblMessage";
            this.lblMessage.Position = 643;
            this.lblMessage.Size = new System.Drawing.Size(773, 62);
            this.lblMessage.TabIndex = 0;
            this.lblMessage.Text = null;
            this.lblMessage.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMessage.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // BaseForm
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Controls.Add(this.BtLayoutPanel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.ImeMode = System.Windows.Forms.ImeMode.AlphaFull;
            this.MaximumSize = new System.Drawing.Size(1280, 1024);
            this.Name = "BaseForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "BaseForm";
            this.Activated += new System.EventHandler(this.BaseForm_Activated);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.BaseForm_FormClosing);
            this.BtLayoutPanel.ResumeLayout(false);
            this.BPanelTop.ResumeLayout(false);
            this.BPanelMainTitle.ResumeLayout(false);
            this.BPanelMainTitle.PerformLayout();
            this.BPanelBottom.ResumeLayout(false);
            this.BPanelBottomRight1.ResumeLayout(false);
            this.BPanelBottomLeft.ResumeLayout(false);
            this.BPanelBottomRight2.ResumeLayout(false);
            this.BPanelBottomMiddle.ResumeLayout(false);
            this.BPanelMain.ClientArea.ResumeLayout(false);
            this.BPanelMain.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer EventTimer;
        private System.Windows.Forms.Timer TimeTimer;
        private System.Windows.Forms.Timer NetworkTimer;
        private System.ComponentModel.BackgroundWorker bgProcess;
        private System.Windows.Forms.TableLayoutPanel BtLayoutPanel;
        private System.Windows.Forms.Panel BPanelBottomLeft;
        protected MESLabel lblNetwork;
        private System.Windows.Forms.Panel BPanelBottomRight2;
        private System.Windows.Forms.Panel BPanelBottomMiddle;
        private Infragistics.Win.Misc.UltraLabel lblTime;
        private Infragistics.Win.Misc.UltraLabel lblDate;
        private System.Windows.Forms.Panel BPanelMainTitle;
        protected MESLabel lblTitle;
        private System.Windows.Forms.Panel BPanelBottom;
        private System.Windows.Forms.Panel BPanelTop;
        private Infragistics.Win.Misc.UltraPanel BPanelMain;
        protected Infragistics.Win.Misc.UltraGroupBox GroupBody;
        public MESMarqueeLabel lblMessage;
        private System.Windows.Forms.Panel lblImage;
        protected MESButton_Top btnRightPage;
        protected MESButton_Top btnLeftPage;
        private System.Windows.Forms.Panel BPanelBottomRight1;
        private MESLabel lblVer_Ip;
        private MESLabel lblWorker;
        private System.Windows.Forms.Label lblMachineName;
    }
}