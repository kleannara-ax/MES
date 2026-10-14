namespace SmartDas.POPUP
{
    partial class DAResultType
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DAResultType));
            this.butcancle = new System.Windows.Forms.Button();
            this.butok = new System.Windows.Forms.Button();
            this.bList_btnDown = new SmartDas.Components.MESButton_Top();
            this.bList_btnUp = new SmartDas.Components.MESButton_Top();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // butcancle
            // 
            this.butcancle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(235)))), ((int)(((byte)(253)))));
            this.butcancle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.butcancle.CausesValidation = false;
            this.butcancle.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butcancle.Font = new System.Drawing.Font("굴림", 26.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butcancle.Location = new System.Drawing.Point(405, 178);
            this.butcancle.Name = "butcancle";
            this.butcancle.Size = new System.Drawing.Size(181, 104);
            this.butcancle.TabIndex = 147;
            this.butcancle.Text = "닫기";
            this.butcancle.UseVisualStyleBackColor = false;
            this.butcancle.Click += new System.EventHandler(this.but_Click);
            // 
            // butok
            // 
            this.butok.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(235)))), ((int)(((byte)(253)))));
            this.butok.CausesValidation = false;
            this.butok.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butok.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butok.Font = new System.Drawing.Font("굴림", 26.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butok.Location = new System.Drawing.Point(206, 178);
            this.butok.Name = "butok";
            this.butok.Size = new System.Drawing.Size(181, 104);
            this.butok.TabIndex = 146;
            this.butok.Text = "확인";
            this.butok.UseVisualStyleBackColor = false;
            this.butok.Click += new System.EventHandler(this.but_Click);
            // 
            // bList_btnDown
            // 
            this.bList_btnDown.AlarmColor = System.Drawing.Color.IndianRed;
            this.bList_btnDown.BackColor = System.Drawing.Color.Transparent;
            this.bList_btnDown.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bList_btnDown.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bList_btnDown.BackgroundImage")));
            this.bList_btnDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bList_btnDown.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bList_btnDown.ButtonPressed = false;
            this.bList_btnDown.ClickBackColor = System.Drawing.Color.Transparent;
            this.bList_btnDown.ExTag = null;
            this.bList_btnDown.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bList_btnDown.FontSize = 24F;
            this.bList_btnDown.LinkButtonBox = null;
            this.bList_btnDown.LinkGrid = null;
            this.bList_btnDown.LinkMoveSize = 0;
            this.bList_btnDown.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bList_btnDown.Location = new System.Drawing.Point(518, 131);
            this.bList_btnDown.Margin = new System.Windows.Forms.Padding(0);
            this.bList_btnDown.Name = "bList_btnDown";
            this.bList_btnDown.ParentBox = null;
            this.bList_btnDown.Size = new System.Drawing.Size(68, 40);
            this.bList_btnDown.TabIndex = 145;
            this.bList_btnDown.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bList_btnDown.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bList_btnDown.UseFlag = true;
            // 
            // bList_btnUp
            // 
            this.bList_btnUp.AlarmColor = System.Drawing.Color.IndianRed;
            this.bList_btnUp.BackColor = System.Drawing.Color.Transparent;
            this.bList_btnUp.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bList_btnUp.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bList_btnUp.BackgroundImage")));
            this.bList_btnUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bList_btnUp.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bList_btnUp.ButtonPressed = false;
            this.bList_btnUp.ClickBackColor = System.Drawing.Color.Transparent;
            this.bList_btnUp.ExTag = null;
            this.bList_btnUp.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bList_btnUp.FontSize = 24F;
            this.bList_btnUp.LinkButtonBox = null;
            this.bList_btnUp.LinkGrid = null;
            this.bList_btnUp.LinkMoveSize = 0;
            this.bList_btnUp.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bList_btnUp.Location = new System.Drawing.Point(518, 78);
            this.bList_btnUp.Margin = new System.Windows.Forms.Padding(0);
            this.bList_btnUp.Name = "bList_btnUp";
            this.bList_btnUp.ParentBox = null;
            this.bList_btnUp.Size = new System.Drawing.Size(68, 40);
            this.bList_btnUp.TabIndex = 144;
            this.bList_btnUp.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bList_btnUp.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bList_btnUp.UseFlag = true;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.Transparent;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Buttons;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 25F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 25F;
            this.bBox1.Location = new System.Drawing.Point(14, 78);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(502, 95);
            this.bBox1.TabIndex = 7;
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(14, 15);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTitle.MoveControl = null;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(572, 53);
            this.lblTitle.TabIndex = 5;
            this.lblTitle.Text = "선택";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // DAResultType
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackgroundImage = global::SmartDas.Properties.Resources.back;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(600, 303);
            this.ControlBox = false;
            this.Controls.Add(this.butcancle);
            this.Controls.Add(this.butok);
            this.Controls.Add(this.bList_btnDown);
            this.Controls.Add(this.bList_btnUp);
            this.Controls.Add(this.bBox1);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "DAResultType";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "DAResultType";
            this.Load += new System.EventHandler(this.DAResultType_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel lblTitle;
        private Components.ButtonBox bBox1;
        protected Components.MESButton_Top bList_btnDown;
        protected Components.MESButton_Top bList_btnUp;
        private System.Windows.Forms.Button butcancle;
        private System.Windows.Forms.Button butok;
    }
}