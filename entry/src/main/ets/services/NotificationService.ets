import notificationManager from '@ohos.notificationManager';
import reminderAgentManager from '@ohos.reminderAgentManager';
import common from '@ohos.app.ability.common';

export interface NotificationResult {
  success: boolean;
  message: string;
}

export class QuitNotificationService {
  private dailyReviewReminderId: number = -1;

  async isEnabled(): Promise<boolean> {
    try {
      return await notificationManager.isNotificationEnabled();
    } catch (error) {
      return false;
    }
  }

  async publishStrictRiskTriple(): Promise<NotificationResult> {
    const enabled = await this.isEnabled();
    if (!enabled) {
      return {
        success: false,
        message: '通知权限未授权，记录已成功；请在系统设置中允许通知。'
      };
    }

    const messages: string[] = [
      '记录已保存。先停 10 秒，看一眼今天的取出次数。',
      '库存正在变成健康负债，这次行为已经写入账本。',
      '不是阻止你，只是打断惯性：回到账本复盘一下。'
    ];

    try {
      for (let index = 0; index < messages.length; index++) {
        if (index > 0) {
          await this.sleep(850);
        }
        await notificationManager.publish({
          id: 4100 + index,
          content: {
            notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
            normal: {
              title: '戒烟有数',
              text: messages[index],
              additionalText: '严厉危害警示'
            }
          }
        });
      }
      return {
        success: true,
        message: '已通过手机系统通知栏发送三连提醒。'
      };
    } catch (error) {
      return {
        success: false,
        message: '系统通知发送失败，记录已成功保留。'
      };
    }
  }

  async requestPermission(context: common.UIAbilityContext): Promise<NotificationResult> {
    try {
      await notificationManager.requestEnableNotification(context);
      return {
        success: true,
        message: '已提交通知权限申请，请按系统提示完成授权。'
      };
    } catch (error) {
      return {
        success: false,
        message: '无法发起通知权限申请，请在系统设置中检查通知权限。'
      };
    }
  }

  async scheduleDailyReview(timeText: string): Promise<NotificationResult> {
    const time = this.parseReviewTime(timeText);
    if (!time) {
      return {
        success: false,
        message: '每日复盘提醒时间无效。'
      };
    }

    try {
      if (this.dailyReviewReminderId >= 0) {
        await reminderAgentManager.cancelReminder(this.dailyReviewReminderId);
      }

      const reminderId = await reminderAgentManager.publishReminder({
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: time.hour,
        minute: time.minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: '戒烟有数',
        content: '到点复盘今天的取出、库存和健康负债。',
        expiredContent: '今日复盘提醒已过期。',
        notificationId: 4200,
        groupId: 'quit-count-daily-review',
        tapDismissed: true
      } as reminderAgentManager.ReminderRequestAlarm);

      this.dailyReviewReminderId = reminderId;
      return {
        success: true,
        message: `每日复盘系统提醒已设置为 ${timeText}。`
      };
    } catch (error) {
      return {
        success: false,
        message: '每日复盘系统提醒设置失败，请检查提醒/通知权限。'
      };
    }
  }

  async cancelDailyReview(): Promise<NotificationResult> {
    if (this.dailyReviewReminderId < 0) {
      return {
        success: true,
        message: '每日复盘系统提醒已关闭。'
      };
    }

    try {
      await reminderAgentManager.cancelReminder(this.dailyReviewReminderId);
      this.dailyReviewReminderId = -1;
      return {
        success: true,
        message: '每日复盘系统提醒已关闭。'
      };
    } catch (error) {
      return {
        success: false,
        message: '每日复盘系统提醒关闭失败，请稍后重试。'
      };
    }
  }

  private parseReviewTime(timeText: string): ReviewTime | undefined {
    const parts = timeText.split(':');
    if (parts.length !== 2) {
      return undefined;
    }
    const hour = Number(parts[0]);
    const minute = Number(parts[1]);
    if (hour !== hour || minute !== minute || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return undefined;
    }
    return { hour: Math.floor(hour), minute: Math.floor(minute) };
  }

  private sleep(milliseconds: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, milliseconds);
    });
  }
}

interface ReviewTime {
  hour: number;
  minute: number;
}
