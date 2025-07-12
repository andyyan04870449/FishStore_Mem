type Role = 'Admin' | 'Manager' | 'Staff';
const hierarchy: Record<Role, number> = { Admin: 3, Manager: 2, Staff: 1 };

export function hasPermission(userRole: string, requiredRole: string | string[]): boolean {
  if (!userRole) return false;
  const userLevel = hierarchy[userRole as Role] || 0;
  if (Array.isArray(requiredRole)) {
    return requiredRole.some(role => userLevel >= (hierarchy[role as Role] || 0));
  }
  return userLevel >= (hierarchy[requiredRole as Role] || 0);
} 