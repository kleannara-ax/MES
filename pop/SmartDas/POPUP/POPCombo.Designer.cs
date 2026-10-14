namespace SmartDas.POPUP
{
    partial class POPCombo
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POPCombo));
            this.labTitle = new SmartDas.Components.MESLabel();
            this.btnLeftPage = new SmartDas.Components.MESButton_Top();
            this.mesGrid1 = new SmartDas.Components.MESGrid();
            this.btnRightPage = new SmartDas.Components.MESButton_Top();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.SuspendLayout();
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.labTitle.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 25F, System.Drawing.FontStyle.Bold);
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(71, 5);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = null;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(237, 60);
            this.labTitle.TabIndex = 86;
            this.labTitle.Text = "Title";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnLeftPage.LinkGrid = this.mesGrid1;
            this.btnLeftPage.LinkMoveSize = 7;
            this.btnLeftPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.btnLeftPage.Location = new System.Drawing.Point(2, 5);
            this.btnLeftPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnLeftPage.Name = "btnLeftPage";
            this.btnLeftPage.ParentBox = null;
            this.btnLeftPage.Size = new System.Drawing.Size(64, 59);
            this.btnLeftPage.TabIndex = 85;
            this.btnLeftPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnLeftPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnLeftPage.UseFlag = true;
            // 
            // mesGrid1
            // 
            this.mesGrid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.mesGrid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.mesGrid1.CountRows = 0;
            this.mesGrid1.DataSource = null;
            this.mesGrid1.FixedCols = 0;
            this.mesGrid1.Font = new System.Drawing.Font("맑은 고딕", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesGrid1.FontSize = 20.25F;
            this.mesGrid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.mesGrid1.HeaderFontSize = 13F;
            this.mesGrid1.HeadString = null;
            this.mesGrid1.Location = new System.Drawing.Point(2, 71);
            this.mesGrid1.Name = "mesGrid1";
            this.mesGrid1.Row = null;
            this.mesGrid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.mesGrid1.SelectCommand = null;
            this.mesGrid1.SelectProcedureName = null;
            this.mesGrid1.Size = new System.Drawing.Size(375, 605);
            this.mesGrid1.TabIndex = 82;
            this.mesGrid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.mesGrid1.GridClick += new SmartDas.Components.MESGrid.gridClick(this.mesGrid1_GridClick);
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
            this.btnRightPage.LinkGrid = this.mesGrid1;
            this.btnRightPage.LinkMoveSize = 7;
            this.btnRightPage.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.btnRightPage.Location = new System.Drawing.Point(311, 5);
            this.btnRightPage.Margin = new System.Windows.Forms.Padding(0);
            this.btnRightPage.Name = "btnRightPage";
            this.btnRightPage.ParentBox = null;
            this.btnRightPage.Size = new System.Drawing.Size(64, 59);
            this.btnRightPage.TabIndex = 84;
            this.btnRightPage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnRightPage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnRightPage.UseFlag = true;
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
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 14.25F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(2, 678);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(375, 72);
            this.btnCancel.TabIndex = 32;
            this.btnCancel.Text = "취   소";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // POPCombo
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(377, 751);
            this.ControlBox = false;
            this.Controls.Add(this.labTitle);
            this.Controls.Add(this.btnLeftPage);
            this.Controls.Add(this.btnRightPage);
            this.Controls.Add(this.mesGrid1);
            this.Controls.Add(this.btnCancel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POPCombo";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POPCombo_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESButton btnCancel;
        private Components.MESGrid mesGrid1;
        protected Components.MESButton_Top btnRightPage;
        protected Components.MESButton_Top btnLeftPage;
        private Components.MESLabel labTitle;
    }
}