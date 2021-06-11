// Based on https://stackoverflow.com/a/365853/12475254

export const degreesToRadians = (degrees: number): number =>
  (degrees * Math.PI) / 180;

export const distanceInKmBetweenEarthCoordinates = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number => {
  const earthRadiusKm = 6371;

  const dLat = degreesToRadians(lat2 - lat1);
  const dLon = degreesToRadians(lon2 - lon1);

  const adjLat1 = degreesToRadians(lat1);
  const adjLat2 = degreesToRadians(lat2);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.sin(dLon / 2) *
      Math.sin(dLon / 2) *
      Math.cos(adjLat1) *
      Math.cos(adjLat2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return earthRadiusKm * c;
};
