using SmartDas.Components;

namespace SmartDas
{
    partial class DA0050
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DA0050));
            this.bLine = new SmartDas.Components.ButtonBox();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.label1 = new System.Windows.Forms.Label();
            this.lblLineCode = new SmartDas.Components.MESLabel();
            this.lblLineName = new SmartDas.Components.MESLabel();
            this.bList_btnDown = new SmartDas.Components.MESButton_Top();
            this.bList_btnUp = new SmartDas.Components.MESButton_Top();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.bList_btnDown);
            this.GroupBody.Controls.Add(this.bList_btnUp);
            this.GroupBody.Controls.Add(this.bLine);
            this.GroupBody.Controls.Add(this.btnCancel);
            this.GroupBody.Controls.Add(this.btnConfirm);
            this.GroupBody.Controls.Add(this.label1);
            this.GroupBody.Controls.Add(this.lblLineCode);
            this.GroupBody.Controls.Add(this.lblLineName);
            // 
            // bLine
            // 
            this.bLine.BackColor = System.Drawing.Color.Transparent;
            this.bLine.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bLine.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bLine.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bLine.CountX = 1;
            this.bLine.CountY = 1;
            this.bLine.CurrentPage = 0;
            this.bLine.ExTag = "";
            this.bLine.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bLine.FontSize = 24F;
            this.bLine.Location = new System.Drawing.Point(15, 153);
            this.bLine.MarginIn = new System.Windows.Forms.Padding(3);
            this.bLine.MarginOut = new System.Windows.Forms.Padding(3);
            this.bLine.Name = "bLine";
            this.bLine.SelectCommand = null;
            this.bLine.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bLine.SelectProcedureName = null;
            this.bLine.Size = new System.Drawing.Size(1250, 688);
            this.bLine.TabIndex = 72;
            this.bLine.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bLine_buttonChangeEvent);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 24F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(1114, 17);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(0);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(154, 120);
            this.btnCancel.TabIndex = 71;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnConfirm.BackColor = System.Drawing.Color.Transparent;
            this.btnConfirm.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnConfirm.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnConfirm.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnConfirm.ButtonPressed = false;
            this.btnConfirm.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnConfirm.DownPic = null;
            this.btnConfirm.ExTag = null;
            this.btnConfirm.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FontSize = 24F;
            this.btnConfirm.LinkButtonBox = null;
            this.btnConfirm.LinkDatePicker = null;
            this.btnConfirm.LinkGrid = null;
            this.btnConfirm.LinkMoveSize = 0;
            this.btnConfirm.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnConfirm.Location = new System.Drawing.Point(949, 17);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(0);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(154, 120);
            this.btnConfirm.TabIndex = 70;
            this.btnConfirm.Text = "확인";
            this.btnConfirm.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnConfirm.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnConfirm.UpPic = null;
            this.btnConfirm.UseFlag = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(14, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(165, 50);
            this.label1.TabIndex = 67;
            this.label1.Text = "작업 라인";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLineCode
            // 
            this.lblLineCode.BackColor = System.Drawing.Color.White;
            this.lblLineCode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLineCode.ColorContent = System.Drawing.Color.Transparent;
            this.lblLineCode.ColorLabel = System.Drawing.Color.White;
            this.lblLineCode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLineCode.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLineCode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLineCode.Location = new System.Drawing.Point(186, 19);
            this.lblLineCode.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLineCode.MoveControl = null;
            this.lblLineCode.Name = "lblLineCode";
            this.lblLineCode.Size = new System.Drawing.Size(180, 50);
            this.lblLineCode.TabIndex = 68;
            this.lblLineCode.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblLineCode.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblLineName
            // 
            this.lblLineName.BackColor = System.Drawing.Color.White;
            this.lblLineName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLineName.ColorContent = System.Drawing.Color.Transparent;
            this.lblLineName.ColorLabel = System.Drawing.Color.White;
            this.lblLineName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLineName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLineName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLineName.Location = new System.Drawing.Point(369, 19);
            this.lblLineName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLineName.MoveControl = null;
            this.lblLineName.Name = "lblLineName";
            this.lblLineName.Size = new System.Drawing.Size(560, 50);
            this.lblLineName.TabIndex = 69;
            this.lblLineName.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblLineName.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.bList_btnDown.LinkButtonBox = this.bLine;
            this.bList_btnDown.LinkGrid = null;
            this.bList_btnDown.LinkMoveSize = 1;
            this.bList_btnDown.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bList_btnDown.Location = new System.Drawing.Point(851, 75);
            this.bList_btnDown.Margin = new System.Windows.Forms.Padding(0);
            this.bList_btnDown.Name = "bList_btnDown";
            this.bList_btnDown.ParentBox = null;
            this.bList_btnDown.Size = new System.Drawing.Size(78, 62);
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
            this.bList_btnUp.LinkButtonBox = this.bLine;
            this.bList_btnUp.LinkGrid = null;
            this.bList_btnUp.LinkMoveSize = 1;
            this.bList_btnUp.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bList_btnUp.Location = new System.Drawing.Point(762, 75);
            this.bList_btnUp.Margin = new System.Windows.Forms.Padding(0);
            this.bList_btnUp.Name = "bList_btnUp";
            this.bList_btnUp.ParentBox = null;
            this.bList_btnUp.Size = new System.Drawing.Size(78, 62);
            this.bList_btnUp.TabIndex = 144;
            this.bList_btnUp.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bList_btnUp.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bList_btnUp.UseFlag = true;
            // 
            // DA0050
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "DA0050";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.DA0050_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private ButtonBox bLine;
        private MESButton btnCancel;
        private MESButton btnConfirm;
        private System.Windows.Forms.Label label1;
        private MESLabel lblLineCode;
        private MESLabel lblLineName;
        protected MESButton_Top bList_btnDown;
        protected MESButton_Top bList_btnUp;


    }
}
