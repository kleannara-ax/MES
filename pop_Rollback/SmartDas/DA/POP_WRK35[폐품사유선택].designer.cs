using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK35
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK35));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblDISPO_NAME = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.bItem_Down = new SmartDas.Components.MESButton_Top();
            this.bItem = new SmartDas.Components.ButtonBox();
            this.bItem_Up = new SmartDas.Components.MESButton_Top();
            this.label12 = new System.Windows.Forms.Label();
            this.bGroup_Down = new SmartDas.Components.MESButton_Top();
            this.bGroup = new SmartDas.Components.ButtonBox();
            this.bGroup_Up = new SmartDas.Components.MESButton_Top();
            this.label11 = new System.Windows.Forms.Label();
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
            this.splitContainer1.Panel1.Controls.Add(this.lblDISPO_NAME);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bItem_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup_Up);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup);
            this.splitContainer1.Panel1.Controls.Add(this.bItem);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
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
            this.lblDISPO_NAME.Location = new System.Drawing.Point(775, 158);
            this.lblDISPO_NAME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDISPO_NAME.MoveControl = null;
            this.lblDISPO_NAME.Name = "lblDISPO_NAME";
            this.lblDISPO_NAME.Size = new System.Drawing.Size(380, 50);
            this.lblDISPO_NAME.TabIndex = 207;
            this.lblDISPO_NAME.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblDISPO_NAME.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Black;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(619, 158);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(150, 50);
            this.label8.TabIndex = 206;
            this.label8.Text = "선택항목";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.bItem_Down.Location = new System.Drawing.Point(1220, 158);
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
            this.bItem.Location = new System.Drawing.Point(11, 213);
            this.bItem.MarginIn = new System.Windows.Forms.Padding(3);
            this.bItem.MarginOut = new System.Windows.Forms.Padding(3);
            this.bItem.Name = "bItem";
            this.bItem.SelectCommand = null;
            this.bItem.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bItem.SelectProcedureName = null;
            this.bItem.Size = new System.Drawing.Size(1255, 570);
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
            this.bItem_Up.Location = new System.Drawing.Point(1164, 158);
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
            this.label12.Location = new System.Drawing.Point(11, 158);
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
            this.bGroup_Down.Location = new System.Drawing.Point(1220, 10);
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
            this.bGroup.Location = new System.Drawing.Point(11, 63);
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
            this.bGroup_Up.Location = new System.Drawing.Point(1164, 10);
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
            this.label11.Location = new System.Drawing.Point(11, 10);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(1150, 50);
            this.label11.TabIndex = 200;
            this.label11.Text = "폐품 그룹";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // POP_WRK35
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK35";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK35_Load);
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
        private ButtonBox bItem;
        private ButtonBox bGroup;
        protected MESButton_Top bItem_Down;
        protected MESButton_Top bItem_Up;
        private System.Windows.Forms.Label label12;
        protected MESButton_Top bGroup_Down;
        protected MESButton_Top bGroup_Up;
        private System.Windows.Forms.Label label11;
        private MESLabel lblDISPO_NAME;
        private System.Windows.Forms.Label label8;

    }
}
