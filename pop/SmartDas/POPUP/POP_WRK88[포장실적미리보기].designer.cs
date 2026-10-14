namespace SmartDas.POPUP
{
    partial class POP_WRK88
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK88));
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.lblIN_PER_CNT = new SmartDas.Components.MESLabel();
            this.lblLabel1 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.btnLeftPage = new SmartDas.Components.MESButton_Top();
            this.btnRightPage = new SmartDas.Components.MESButton_Top();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
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
            this.Grid1.Location = new System.Drawing.Point(6, 124);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1204, 501);
            this.Grid1.TabIndex = 154;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnConfirm.Location = new System.Drawing.Point(856, 637);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(160, 57);
            this.btnConfirm.TabIndex = 139;
            this.btnConfirm.Text = "예";
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
            this.btnCancel.Location = new System.Drawing.Point(1047, 637);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(160, 57);
            this.btnCancel.TabIndex = 86;
            this.btnCancel.Text = "아니오";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // lblIN_PER_CNT
            // 
            this.lblIN_PER_CNT.BackColor = System.Drawing.Color.White;
            this.lblIN_PER_CNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblIN_PER_CNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblIN_PER_CNT.ColorLabel = System.Drawing.Color.White;
            this.lblIN_PER_CNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblIN_PER_CNT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblIN_PER_CNT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblIN_PER_CNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblIN_PER_CNT.Location = new System.Drawing.Point(150, 76);
            this.lblIN_PER_CNT.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblIN_PER_CNT.MoveControl = null;
            this.lblIN_PER_CNT.Name = "lblIN_PER_CNT";
            this.lblIN_PER_CNT.Size = new System.Drawing.Size(121, 40);
            this.lblIN_PER_CNT.TabIndex = 141;
            this.lblIN_PER_CNT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblIN_PER_CNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblLabel1
            // 
            this.lblLabel1.BackColor = System.Drawing.Color.Gray;
            this.lblLabel1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel1.ForeColor = System.Drawing.Color.White;
            this.lblLabel1.Location = new System.Drawing.Point(9, 76);
            this.lblLabel1.Name = "lblLabel1";
            this.lblLabel1.Size = new System.Drawing.Size(134, 40);
            this.lblLabel1.TabIndex = 140;
            this.lblLabel1.Text = "속당 매수";
            this.lblLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.BackColor = System.Drawing.Color.Transparent;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 22F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.Location = new System.Drawing.Point(654, 76);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(550, 41);
            this.label1.TabIndex = 155;
            this.label1.Text = "아래의 정보로 포장실적이 등록 됩니다.";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.label1.Visible = false;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.BackColor = System.Drawing.Color.Transparent;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 22F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.Location = new System.Drawing.Point(0, 645);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(444, 41);
            this.label2.TabIndex = 156;
            this.label2.Text = "포장실적을 등록 하시겠습니까?";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
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
            this.btnLeftPage.Location = new System.Drawing.Point(7, 6);
            this.btnLeftPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnLeftPage.Name = "btnLeftPage";
            this.btnLeftPage.ParentBox = null;
            this.btnLeftPage.Size = new System.Drawing.Size(64, 59);
            this.btnLeftPage.TabIndex = 159;
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
            this.btnRightPage.Location = new System.Drawing.Point(1143, 6);
            this.btnRightPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnRightPage.Name = "btnRightPage";
            this.btnRightPage.ParentBox = null;
            this.btnRightPage.Size = new System.Drawing.Size(64, 59);
            this.btnRightPage.TabIndex = 158;
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
            this.labTitle.Location = new System.Drawing.Point(80, 6);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(1058, 59);
            this.labTitle.TabIndex = 157;
            this.labTitle.Text = "포장 실적 등록 미리보기";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK88
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(1216, 701);
            this.ControlBox = false;
            this.Controls.Add(this.btnLeftPage);
            this.Controls.Add(this.btnRightPage);
            this.Controls.Add(this.labTitle);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.Grid1);
            this.Controls.Add(this.lblLabel1);
            this.Controls.Add(this.lblIN_PER_CNT);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.btnCancel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_WRK88";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK88_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESButton btnCancel;
        private Components.MESButton btnConfirm;
        private Components.MESGrid Grid1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblLabel1;
        private Components.MESLabel lblIN_PER_CNT;
        protected Components.MESButton_Top btnLeftPage;
        protected Components.MESButton_Top btnRightPage;
        private Components.MESLabel labTitle;
    }
}